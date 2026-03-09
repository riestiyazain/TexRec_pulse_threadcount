# TexRec Thread Counting and Clustering

## Overview
This repository provides MATLAB scripts for extracting thread counts and performing clustering analysis on textile fragments. The main workflow is implemented in the `ExtractingThreadcountsAll.m` file, which processes image patches, counts threads, and applies clustering techniques to analyze textile samples.

## Main Script: ExtractingThreadcountsAll.m
- **Purpose:** Automates thread counting and clustering for textile fragment images.
- **Features:**
  - Processes folders containing 1x1 cm image patches of textile fragments.
  - Applies Gaussian blur and thread counting algorithms.
  - Supports single and double-threaded counting mechanisms.
  - Computes thread density using thresholding and gradient methods.
  - Aggregates results and performs k-means clustering.
  - Visualizes clustering results and compares with ground truth labels.
  - Includes silhouette and elbow methods for cluster evaluation.

## Folder Structure
- `images/` — Contains image patches and subfolders for different fragments. Send email to riestiya.z.fadillah@ntnu.no for dataset access. 
- MATLAB scripts:
  - `ExtractingThreadcountsAll.m` (main workflow)
  - Supporting scripts for thread counting, clustering, and visualization.

## Requirements
- MATLAB (with Parallel Computing Toolbox)
- Image patches in PNG format, organized in subfolders (each representing a fragment)

## Usage
1. **Setup:**
   - Place all scripts in your MATLAB working directory.
   - Ensure image patches are organized in subfolders under the current directory.
   - Add the project path in MATLAB if needed.

2. **Run the Main Script:**
   - Open `ExtractingThreadcountsAll.m` in MATLAB.
   - Adjust parameters (e.g., `blur`, `double_thread`, `k`) as needed.
   - Run the script. It will process all subfolders, count threads, and perform clustering.

3. **Results:**
   - Clustering results and visualizations will be displayed.
   - Tables summarizing thread densities and cluster assignments are generated.

## Parameters
- `blur`: Gaussian blur applied before thread counting (default: 1).
- `double_thread`: Counting mechanism (0 = single, 2 = double; default: 1).
- `k`: Number of clusters for k-means (default: 5).

## Clustering Evaluation
- Silhouette and elbow methods are included to assess clustering quality.
- Ground truth clusters can be compared with results for validation.

## Customization
- Change feature selection for clustering (threshold or gradient-based) in the script.
- Adjust cluster number and ground truth labels as needed.

## Citation
@article{fadillah2026automated,
  title={Automated thread counting in archaeological textiles using pulse-based feature extraction},
  author={Fadillah, Riestiya Zain and Gigilashvili, Davit and Havgar, Margrethe and Vedeler, Marianne and Hardeberg, Jon Yngve},
  journal={The European Physical Journal Plus},
  volume={141},
  number={1},
  pages={24},
  year={2026},
  publisher={Springer}
}
