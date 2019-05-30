# This script updates the Azure CLI, the Azure Machine Learning CLI, and the Azure Machine Learning Services Python SDK on Linux

# update the CLI and the Azure Machine Learning CLI
az extension remove -n azure-cli-ml
az extension add -n azure-cli-ml

# set up the azure machine learning services environment
# (note, the DSVM does not provide an environment)
conda create -n azureml -y Python=3.6 ipywidgets nb_conda

conda activate azureml
pip install --upgrade azureml-sdk[notebooks,contrib] scikit-image tensorflow tensorboardX azure-cli-core --user 
jupyter nbextension install --py --user azureml.widgets
jupyter nbextension enable azureml.widgets --user --py