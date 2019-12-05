# Setup environment
#source /afs/slac.stanford.edu/g/reseng/vol26/anaconda/miniconda3/etc/profile.d/conda.sh
# conda activate rogue_v3.5.0
#conda activate rogue_pre-release
# clone rogue (https://github.com/slaclab/rogue), set up the conda env, and load it up here
export CONDA_EXE='/home/mattfel/anaconda3/bin/conda'
export CONDA_PYTHON_EXE='/home/mattfel/anaconda3/bin/python'
export PATH="/home/mattfel/anaconda3/bin:$PATH"
export PYTHONPATH=$PYTHONPATH:/home/mattfel/anaconda3/envs/rogue_pre/lib/python3.7/site-packages
source /home/mattfel/anaconda3/etc/profile.d/conda.sh
conda activate rogue_pre
