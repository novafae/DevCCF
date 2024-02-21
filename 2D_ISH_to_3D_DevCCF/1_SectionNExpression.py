import pandas as pd
import itk
import SimpleITK as sitk
import os
import sys
import json
import argparse
import logging

class AllenDatasetBuilder:

    downsample = 8 # downsample = 2^3
    #path="/Users/jtduda/projects/Allen/Downsampled/example_batch_with_alignment"
    #atlasPath="/Users/jtduda/projects/Allen/Downsampled/atlas_models"
    specimenDatasets=None
    mapFile=None
    path=None
    atlasPath=None
    overwrite=False

    # path is a directory that contains a "section_datasets_metadata.csv" file
    def set_path(self, path):
        self.path = path
        self.mapFile = os.path.join(self.path, "section_datasets_metadata.csv")
        if not os.path.exists(self.mapFile):
            logging.error("ERROR: Invalid path, "+self.mapFile+" not found")
            self.mapFile=None
            self.path=None

    def set_atlas_path(self, path):
        self.atlasPath = path

    def set_overwrite(self, overwrite):
        self.overwrite=overwrite

    # Define map from specimen id -> dataset ids
    def map_specimen_datasets(self):

        logging.debug("map_specimen_dataset()")
        self.specimenDatasets = {}
        if self.mapFile is None:
            logging.error( "ERROR: Path not set")
            return(None)

        masterDat = pd.read_csv(self.mapFile)
        specimen_ids = set(masterDat['specimen_id'])
        for specimen in specimen_ids:
            datasets = set(masterDat['section_dataset_id'][ masterDat['specimen_id']==specimen])
            self.specimenDatasets[str(specimen)] = datasets

    # get all specimen ids
    def get_specimens(self):
        if self.specimenDatasets is None:
            self.map_specimen_datasets()
        return(self.specimenDatasets.keys())

    # Get list of dataset ids for a given specimen
    def get_specimen_datasets(self, specimen_id):
        logging.debug("AllenDatasetBuilder.get_specimen_datesets("+str(specimen_id)+")")
        if self.specimenDatasets is None:
            self.map_specimen_datasets()
        return( self.specimenDatasets[specimen_id] )
        
    # Get relevant info for a dataset
    def get_dataset_info(self, dataset_id):
        fname = os.path.join(self.path, str(dataset_id), "alignment_"+str(dataset_id)+".json")
        data={}
        if os.path.exists(fname):
            with open(fname,"r") as file:
                payload = json.load(file)
                payload = payload[0]
                data['specimen_id'] = payload['specimen_id']
                data['dataset_id'] = payload['id']
                data['treatment'] = payload['treatments'][0]['name']
                data['plane_of_section'] = payload['plane_of_section']['name']
                data['age'] = payload['specimen']['donor']['age']['name']
                data['section_thickness'] = payload['section_thickness']

        else:
            print("ERROR: could not find "+fname)

        masterDat = pd.read_csv(self.mapFile)
        data['gene_symbol'] = masterDat['gene_symbol'][ masterDat['section_dataset_id']==data['dataset_id'] ].values[0]

        return(data)

    def get_dataset_images(self, dataset_id, type='section'):
        logging.debug("AllenDatasetBuilder.get_dataset_images("+str(dataset_id)+",type="+type+")")

        if not type in ['section', 'expression']:
            logging.error("Invalid image type: "+str(type))
            return(None)

        fname = os.path.join(self.path, str(dataset_id), "alignment_"+str(dataset_id)+".json")
        data=[]

        masterDat = pd.read_csv(self.mapFile)

        gene = masterDat['gene_symbol'][ masterDat['section_dataset_id']==dataset_id ].values[0]

        if os.path.exists(fname):
            with open(fname,"r") as file:
                payload = json.load(file)
                payload = payload[0]
                section_images = payload['section_images']

                for img in section_images:
                    idata={}
                    idata['specimen_id'] = payload['specimen_id']
                    idata['dataset_id'] = payload['id']
                    idata['treatment'] = payload['treatments'][0]['name']
                    idata['gene_symbol'] = gene
                    idata['plane_of_section'] = payload['plane_of_section']['name']
                    idata['age'] = payload['specimen']['donor']['age']['name']
                    idata['section_thickness'] = payload['section_thickness']
                    idata['section_number'] = int(img['section_number'])
                    idata['width'] = int(img['width'])
                    idata['height'] = int(img['height'])
                    idata['resolution'] = img['resolution']
                    
                    sectionStr = "%04d" % (idata['section_number'])
                    imgFileName=None
                    if type=='section' and os.path.exists( os.path.join(self.path, str(idata['dataset_id']), "section_images")):
                        imgFileName = os.path.join(self.path, str(idata['dataset_id']), "section_images", sectionStr + "_"+str(idata['dataset_id'])+".jpg")
                    else:
                        if type=='expression' and os.path.exists( os.path.join(self.path, str(idata['dataset_id']), "expression_images")):
                            if idata['treatment']=="NISSL":
                                logging.debug(str(dataset_id)+" treatement is NISSL. Ignoring expression images")
                            else:
                                imgFileName = os.path.join(self.path, str(idata['dataset_id']), "expression_images", sectionStr + "_"+str(idata['dataset_id'])+".jpg")

                    if not imgFileName is None:
                        if os.path.exists(imgFileName):
                            idata['filename'] = imgFileName
                            a2d = img['alignment2d']
                            idata['tvs_00'] = float(a2d['tvs_00'])
                            idata['tvs_01'] = float(a2d['tvs_01'])
                            idata['tvs_02'] = float(a2d['tvs_02'])
                            idata['tvs_03'] = float(a2d['tvs_03'])
                            idata['tvs_04'] = float(a2d['tvs_04'])
                            idata['tvs_05'] = float(a2d['tvs_05'])   
                            data.append(idata)
                        else:
                            logging.error("Could not find expected file: "+imgFileName)
                    
        else:
            logging.warning("Could not find alignment file: "+fname)

        return(data)


    def get_specimen_info(self, specimen_id):
        sDat = []
        for d in self.get_specimen_datasets(specimen_id):
            dDat = self.get_dataset_info(d)
        return(dDat)

    def specimen_info(self, specimen_id):
        logging.debug("AllenDatasetBuilder.specimen_info("+str(specimen_id)+")")
        datasets = self.get_specimen_datasets(specimen_id)
        datasetNames = [str(x) for x in datasets]
        imgDat = []
        for d in datasets:
            dImg = self.get_dataset_images(d, type="section")
            imgDat.extend(dImg)
        imgDat = pd.DataFrame(imgDat)
        return(imgDat)

    def build_specimen(self, specimen_id):
        logging.debug("AllenDatasetBuilder.build_specimen("+str(specimen_id)+")")

        datasets = self.get_specimen_datasets(specimen_id)
        datasetNames = [str(x) for x in datasets]
        logging.info("Datasets: "+",".join(datasetNames))

        imgDat = []
        expDat = []
        for d in datasets:
            dImg = self.get_dataset_images(d, type="section")
            imgDat.extend(dImg)
            eImg = self.get_dataset_images(d, type="expression")
            expDat.extend(eImg)
            #logging.debug("ID: "+str(specimen_id)+" Dataset: "+str(d)+" type: section nSlices: "+str(len(dImg)) )
            #logging.debug("ID: "+str(specimen_id)+" Dataset: "+str(d)+" type: expression nSlices: "+str(len(eImg)) )

        logging.debug("ID: "+str(specimen_id)+" nDatasets: "+str(len(datasets))+" type: section    nSlices: "+str(len(imgDat)) )
        logging.debug("ID: "+str(specimen_id)+" nDatasets: "+str(len(datasets))+" type: expression nSlices: "+str(len(expDat)) )

        imgDat = pd.DataFrame(imgDat)
        expDat =  pd.DataFrame(expDat)

        age = imgDat['age'][0]
        plane = imgDat['plane_of_section'][0]
        xyres = imgDat['resolution'][0] * self.downsample
        zres = float(imgDat['section_thickness'][0])

        atlasInfo =  self.get_atlas_info(age, plane)

        xsize = int(round(atlasInfo['width'] / xyres, 0 ))
        ysize = int(round(atlasInfo['height'] / xyres, 0 ))
        zsize = max(imgDat['section_number']) + 1

        maxX = int(max(imgDat['width'])/self.downsample)
        maxY = int(max(imgDat['height'])/self.downsample)

        imgX = atlasInfo['image_size'][0] * atlasInfo['image_spacing'][0] / xyres
        imgY = atlasInfo['image_size'][1] * atlasInfo['image_spacing'][1] / xyres

        mintx=0
        maxtx=-5000
        minty=0
        maxty=-5000

        irangeX = (0, int(max(imgDat['width'])/self.downsample)*xyres)
        irangeY = (0, int(max(imgDat['height'])/self.downsample)*xyres)

        for index, row in imgDat.iterrows():
            dx = row['tvs_04']
            dy = row['tvs_05']
            if dx < mintx:
                mintx=dx
            if dx > maxtx:
                maxtx = dx
            if dy < minty:
                minty=dy
            if dy > maxty:
                maxty=dy

        orangeX = ( irangeX[0]-maxtx, irangeX[1]-mintx )
        orangeY = ( irangeY[0]-maxty, irangeY[1]-minty )

        image2d = sitk.Image( (xsize, ysize), sitk.sitkVectorUInt8, 3)
        image2d.SetSpacing( (xyres,xyres) )        
        image2d.SetOrigin( (0,0) )

        selfRef = sitk.Image( (maxX, maxY), sitk.sitkVectorUInt8, 3)
        selfRef.SetSpacing( (xyres,xyres) )
        selfRef.SetOrigin( (0.0,0.0) )

        section3dres = sitk.Image( (xsize, ysize, zsize), sitk.sitkVectorUInt8, 3)
        section3dres.SetSpacing( (xyres, xyres, zres ))
        section3dres.SetOrigin((0,0,0))

        exp3dres = sitk.Image( (xsize, ysize, zsize), sitk.sitkVectorUInt8, 3)
        exp3dres.SetSpacing( (xyres, xyres, zres ))
        exp3dres.SetOrigin((0,0,0))

        #minZ = min(imgDat['section_number'])

        for index, row in imgDat.iterrows():
            img = sitk.ReadImage(row['filename'])
            img.SetSpacing((xyres, xyres))
            img.SetSpacing( (8,8) )
            num = "%04d" % (row['section_number'])

            tvs = sitk.AffineTransform(2)
            tvs.SetParameters( (row['tvs_00'],row['tvs_01'],row['tvs_02'],row['tvs_03'],row['tvs_04'],row['tvs_05'] ) )
            resampled = sitk.Resample(img, image2d, transform=tvs, defaultPixelValue=255)
            section3dres[:,:,row['section_number']] = resampled

        for index, row in expDat.iterrows():
            img = sitk.ReadImage(row['filename'])
            img.SetSpacing((xyres, xyres))
            img.SetSpacing( (8,8) )
            num = "%04d" % (row['section_number'])

            tvs = sitk.AffineTransform(2)
            tvs.SetParameters( (row['tvs_00'],row['tvs_01'],row['tvs_02'],row['tvs_03'],row['tvs_04'],row['tvs_05'] ) )
            resampled = sitk.Resample(img, image2d, transform=tvs, defaultPixelValue=255)
            exp3dres[:,:,row['section_number']] = resampled

        imgDat = imgDat.sort_values(by='section_number')

        return( (imgDat, section3dres, exp3dres) )

    def get_atlas_info(self, age, plane_of_section):
        atlasImageName = os.path.join(self.atlasPath, age, plane_of_section, "atlasVolume.nii.gz")
        atlasJsonName = os.path.join(self.atlasPath, "atlas_metadata.json")

        with open(atlasJsonName,"r") as file:
            payload = json.load(file)

        ssize = payload[age][plane_of_section]['standard_size']
        isize = payload[age][plane_of_section]['atlas']['size']
        ispacing = payload[age][plane_of_section]['atlas']['spacing']
        w = ssize['width']

        ret = { 'width': ssize['width'], 'height': ssize['height'], 'image_size': isize, 'image_spacing': ispacing }
        return(ret)


def main():

    print("SectionNExpression.py has started")
    logging.basicConfig(
        format='%(asctime)s %(name)s %(levelname)-8s %(message)s',
        level=logging.DEBUG,
        datefmt='%Y-%m-%d %H:%M:%S')

    try:
        my_parser = argparse.ArgumentParser(description='Build specimen volume')
        my_parser.add_argument('-p', '--path', type=str, help='the path to the directory where datasets are stored', required=True)
        my_parser.add_argument('-a', '--atlas_path', type=str, help='the path to the directory where atlases are stores', required=True)
        my_parser.add_argument('-o', '--outdir', type=str, help='the path to the output directory', required=True)
        my_parser.add_argument('-s', '--specimen', type=str, help='id of specimen to build', required=False)
        my_parser.add_argument('-f', '--force', default=False, action='store_true')
        args = my_parser.parse_args()
        print(args)

        path=args.path
        atlas_path=args.atlas_path
        outdir=args.outdir
        specimen=args.specimen
        force=args.force
    except:
        print('pareser failed')
        path="/gpfs/Home/cuk476/GeneExpression/20231027_all_coronal_batch/all_coronal_batch/"
        atlas_path="/gpfs/Home/cuk476/GeneExpression/0_atlas_models/"
        outdir = "/gpfs/Home/cuk476/GeneExpression/20231027_all_coronal_batch/1_subjects/"
        specimen=None
        force=False
        
        
    pd.set_option('display.max_rows', 100000)
    pd.set_option('display.max_columns', 20)
    pd.set_option('display.width', 5000)

    eng = AllenDatasetBuilder()
    eng.set_overwrite(force) 
    eng.set_atlas_path(atlas_path) # /gpfs/Home/cuk476/GeneExpression/0_atlas_models/
    eng.set_path(path) # /gpfs/Home/cuk476/GeneExpression/20231027_all_coronal_batch/all_coronal_batch/
    #args.outdir = "/gpfs/Home/cuk476/GeneExpression/20231027_all_coronal_batch/1_subjects/"
    
    specimenList = eng.get_specimens()
    print( eng.specimenDatasets )

    if not specimen is None:
        specimenList = [specimen]

    for count, s in enumerate(specimenList):
        
        logging.info("Specimen: "+str(s))
        logging.info(str(count+1)+" of "+str(len(specimenList)))

        specimen_exists = True
        specimen_info = eng.specimen_info(s)

        if specimen_info.shape[0]==0:
            logging.warning("No data for specimen "+str(s))
            specimen_exists=False

        if specimen_exists:
            age=specimen_info["age"][0]
            age=age.replace(".", "x")
            dir=specimen_info["plane_of_section"][0]

            oImgName = os.path.join(outdir, str(s)+"_"+age+"_"+dir+"_section.nii.gz")
            oExpName = os.path.join(outdir, str(s)+"_"+age+"_"+dir+"_expression.nii.gz")

            if not os.path.exists(atlas_path + age.replace("x", ".") ):
                print('This age (' + age + ') is not set up')
                continue

            if not os.path.exists(oImgName) or force:

                try:
                    print('Building Specimen: ' + os.path.basename(oImgName))
                    (volumeInfo, volumeImg, expressionImg) = eng.build_specimen(s)
                except:
                    print('  WARNING: Could not build specimen')
                    print('  Skipping...')
                    continue

                age=volumeInfo["age"][0]
                age=age.replace(".", "x")
                dir=volumeInfo["plane_of_section"][0]

                volumeInfo.drop(columns=['filename'], inplace=True)
                volumeInfo.to_csv(os.path.join(outdir, str(s)+"_"+age+"_"+dir+"_metainfo.csv"), index=False)

                if dir=="sagittal":
                    volumeImg.SetDirection((0, 0, -1, 1, 0, 0, 0, -1, 0))
                    expressionImg.SetDirection((0, 0, -1, 1, 0, 0, 0, -1, 0))
                if dir=="coronal":
                    volumeImg.SetDirection(( 1, 0, 0, 0, 0, -1, 0, -1, 0))
                    expressionImg.SetDirection(( 1, 0, 0, 0, 0, -1, 0, -1, 0))

                sp=volumeImg.GetSpacing()
                volumeImg.SetSpacing( (sp[0]/1000, sp[1]/1000, sp[2]/1000)  )

                sitk.WriteImage(volumeImg, oImgName)
                logging.info("Wrote file: "+oImgName)

                sitk.WriteImage(expressionImg, oExpName)
                logging.info("Wrote file: "+oExpName)

            else:
                logging.warning("Output already exists. Rerun using --force to overwrite output")
                # print(args)

        #if not os.path.exists(oExpName) or force:

        #    if dir=="sagittal":
        #        expressionImg.SetDirection((0, 0, -1, 1, 0, 0, 0, -1, 0))
        #    if dir=="coronal":
        #        expressionImg.SetDirection(( 1, 0, 0, 0, 0, -1, 0, -1, 0))

        #    sp=expressionImg.GetSpacing()
        #    expressionImg.SetSpacing( (sp[0]/1000, sp[1]/1000, sp[2]/1000)  )

if __name__=="__main__":
    sys.exit(main())
