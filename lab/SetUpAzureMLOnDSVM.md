# Set up your Data Science Virtual Machine for Azure Machine Learning services

Use the following steps to set up the Machine Learning services on your development platform.

This set up helps insure that you can share data among your team, while at the same time, keeping data confidential.
In addition, the set up allows administrators to set restrictions on usage to keep your budget from going crazy.

## Prerequisites

You can use your own development system or a [Azure Data Science Virtual Machine](https://docs.microsoft.com/en-us/azure/machine-learning/data-science-virtual-machine/overview).

## Set up development system

Your development system can be Windows or Linux. The machine learning run will run on Linux.

## Data Science Virtual Machine on DVSM

If you are using a [Data Science virtual machine (DSVM)](https://azure.microsoft.com/en-us/services/virtual-machines/data-science-virtual-machines/):

1. [Review what is already installed on the DSVM](https://docs.microsoft.com/en-us/azure/machine-learning/data-science-virtual-machine/dsvm-deep-learning-ai-frameworks)
2. Install [X2Go](https://wiki.x2go.org/doku.php/doc:installation:x2goclient) client on your desktop.
3. Run the X2Go client, and select **New Session**. [Set the configuration dialog box](https://docs.microsoft.com/en-us/azure/machine-learning/data-science-virtual-machine/dsvm-ubuntu-intro#x2go).

## Note about copy and paste

You can copy the text from GitHub and paste it into the command shell on X2Go using the center button of a three-button mouse.
From Windows you can use the center wheel as the center button on some mouses.

## Next steps

Continue the set up process on the [ReadMe](ReadMe.md).

## References

- [Data Science Virtual Machine (DSVM)](https://docs.microsoft.com/en-us/azure/machine-learning/data-science-virtual-machine/overview)

