import pandas as pd
import itk
import SimpleITK as sitk
import os
import sys
import json
import argparse
import logging
import numpy as np


def main():

    print("ExtractGenes.py has started")
    logging.basicConfig(
        format='%(asctime)s %(name)s %(levelname)-8s %(message)s',
        level=logging.DEBUG,
        datefmt='%Y-%m-%d %H:%M:%S')

    my_parser = argparse.ArgumentParser(description='Build specimen volume')
    my_parser.add_argument('-i', '--input', type=str, help='image volume with gene expression maps', required=True)
    my_parser.add_argument('-m', '--meta', type=str, help='csv file with meta info', required=True)
    my_parser.add_argument('-o', '--outdir', type=str, help='the path to the output directory', required=True)
    my_parser.add_argument('-s', '--specimen', type=str, help='id of specimen to build', required=False)
    my_parser.add_argument('-f', '--force', default=False, action='store_true')
    args = my_parser.parse_args()

    pd.set_option('display.max_rows', 100000)
    pd.set_option('display.max_columns', 20)
    pd.set_option('display.width', 5000)

    meta = pd.read_csv(args.meta)
    genes = meta.gene_symbol.unique()
    genes = [ x for x in genes if not pd.isna(x)]

    img = sitk.ReadImage(args.input)

    outname = os.path.basename(args.input)
    outname = outname.split(".nii")[0]
    print(' ' + outname)

    for g in genes:
        geneArr = sitk.GetArrayFromImage(img)
        slices = meta.section_number[ meta.gene_symbol==g ].tolist()

        for z in range(geneArr.shape[0]):
            if not z in slices:
                geneArr[z,:,:,:]=0

        geneImg = sitk.GetImageFromArray(geneArr, isVector=True)
        geneImg.SetSpacing(img.GetSpacing())
        geneImg.SetDirection(img.GetDirection())
        geneImg.SetOrigin(img.GetOrigin())
        oName = os.path.join(args.outdir, outname+"_"+g+".nii.gz")
        os.makedirs(os.path.dirname(oName), exist_ok=True)
        sitk.WriteImage(geneImg, oName)



if __name__=="__main__":
    sys.exit(main())
