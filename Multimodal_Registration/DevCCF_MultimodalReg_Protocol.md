# Manual Landmark Registration Steps
This is the protocol for performing multimodal registration as in the DevCCF.

**Last Update:** 20240221  
**Author:** Fae Nova  

## System Requirements
- Windows 10 or 11
  - Windows Subsystem Linux 2 Installed
- ANTs (for Registration)
- Avizo (recommended) or ITK-SNAP or FIJI (for Segmentation)
- Python (recommended) or MATLAB
  - ANTsPy (recommended for image manipulation)

## Other Helpful Guides to Get Started:
- [Installing WSL2](https://msdn.microsoft.com/en-us/commandline/wsl/install_guide)
- [ANTs Wiki](https://github.com/ANTsX/ANTs/wiki)
- [Installing ANTs on Windows](https://github.com/ANTsX/ANTs/wiki/Compiling-ANTs-on-Windows-10)
- [Installing ANTs on Linux/Mac](https://github.com/ANTsX/ANTs/wiki/Compiling-ANTs-on-Linux-and-Mac-OS)
- [Installing ANTsPy](https://github.com/ANTsX/ANTsPy)
- [Learning about ANTs Registration Parameters](https://github.com/ANTsX/ANTs/wiki/Anatomy-of-an-antsRegistration-call)
- [Template Building](https://github.com/ANTsX/ANTsR/wiki/general-questions-about-how-to-build-a-template)
- [Avizo Tutorial](https://www.youtube.com/playlist?list=PLoxdPzacxPYjDVMD4tPCaVbuQjxYizr_g)


## Multimodal Registration Protocol

### **Data Setup and Initial Registration:**
   1. **Select Input**: Template images should be in Nifti format.
   2. **Resample** 3D Template Images to Desired Registration Resolution (using MATLAB, ANTs, ANTsPy, or similar)
   3. Make sure image **metadata** is properly set:
        - Resolution
        - Orientation
   4. **Registration 1**: ANTs Quick Register Moving  --> Target (using `antsRegistrationQuickSyN` with default MI metric).

### **Manual Landmark Segmentation:**
   5. **Review results** for misaligned areas using ITK-SNAP.
   6. Create **brain masks** for both whole brain images in moving space.
        - 0: not brain
        - 1: brain
   7. Create matching **ROI masks** for poorly aligned areas of both templates in moving space.
        - **Tips**: 
          - Focus on internal structures, rather than external
          - Use thick structers over thin ones
          - Select as few ROIs as possible.
          - Fix boundaries using landmarks from neigbhoring regions with good contrast features.
   8. **Remove poorly aligned ROI landmarks from whole brain masks** for each template:
        - 0: not brain and misaligned ROIs
        - 1: remaining brain areaCreate a masks representing all ROIs for both moving & fixed images.

### **Registration 2:**
   9. Register **Moving mask --> Target Mask** using `DevCCF_MultimodalReg.sbatch`
        - if performing ROI masking in moving space, Advanced User input `initial_transform=0`
        - If performing ROI masking in modality native spaces, Advanced User input
          -  `initial_transform=1`
          -  `initial_transforms_outputPrefix` set to output directory from **Registration 1**
  10.   Optionally, set `include_data` to include templates with mutual info metric, but it may take longer to run and may hurt registration. Value represents weight this registration compared to the labels (e.g. 0 is not at all, 1 is the same, .5 is half weight).

### **Quality Check**
   11. **Review results**. If not satisfactory, go back to step 3 and edit your landmarks or add alternate/additional landmarks

### **Registration 3 (Optional):**
   12. Once your images are well aligned, you may optionally yegister initial moving image --> moving image at target space (if needed) using ANTs `antsRegistrationSyN.sh` with default parameters
       - This can help generate a smoother transform if there is a lot of warping in the final produce, however, it may also make things worse.

