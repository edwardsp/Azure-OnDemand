# Setting up the environment

Setup Azure OnDemand Slurm setup (see README here: https://github.com/edwardsp/Azure-OnDemand)

## What do we cover here

These instructions will walk you through the Jupyter Notebook example Tensorflow scenario.  Features include:

* Launch Jupyter Notebook server
* Connect to Jupyter
* Upload a notebook and run 
* Visualize with Tensorboard

## Walkthorugh

1. Launch Azure OnDemand Portal
2. In the "Interactive Apps" drop down select "Jupyter Notebook"
3. Update the parameters if needed and click "Launch"
4. Once the server is ready you will see "Connect to Jupyter" option to launch Jupyter
5. Select "Upload" and load a notebook -- see the example notebook Tensorflow.ipynb that is in this folder derived from [here](https://github.com/tensorflow/tensorboard/blob/master/docs/tensorboard_in_notebooks.ipynb)
6. Now open the notebook and run
7. The sample notebook above creates logs in the "logs" directory. 
8. The next step will be to view the logs using the Jupyter Tensorboard plugin installed from [here](https://pypi.org/project/jupyter-tensorboard/). You can just go to the Jupyter server home page and Select Tensorboard under "New". Specify the log directory and click OK. This will open tensorboard in a new browser window and you can visualize your results as you run through you notebook.  


