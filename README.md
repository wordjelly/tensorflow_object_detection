Instructions for setting up and using Object Detection API with tensorflow

Tutorials Used:
----------------

a. https://towardsdatascience.com/building-a-toy-detector-with-tensorflow-object-detection-api-63c0fdf2ac95

b.https://medium.com/google-cloud/object-detection-tensorflow-and-google-cloud-platform-72e0a3f3bdd6

c. https://pythonprogramming.net/introduction-use-tensorflow-object-detection-api-tutorial/

d. https://github.com/tensorflow/models/blob/master/research/object_detection/g3doc/running_pets.md


Installation:
--------------

1. Installing tensorflow
	1.To install tensorflow first install anaconda. Then follow the instructions at this webpage under the anaconda section:
	https://www.tensorflow.org/versions/r1.5/install/install_linux#installing_with_anaconda
	
	2. Inside the conda environment, all python packages need to be installed again, this can be done with:

	```
	pip install pillow
	pip install lxml
	pip install jupyter
	pip install matplotlib
	```


2. Installing Object Detection API, Setting path.
	Inside a folder in your machine, clone the following repositories:
	
	1.tensorflow : https://github.com/tensorflow/tensorflow.git
		Nothing special to do after cloning. This repository is used only later to do the predictions.
	2.tensorflow/models : https://github.com/tensorflow/models.git
		After downloading this repository, follow the instructions from this webpage
		Remember to run all the following commands from the models/research folder.
		There are a few main things that need to be done:
		a. Protobuf installation/configuration:
			Run the following command from the models/research directory. 
			
			```
			protoc object_detection/protos/*.proto --python_out=.
			```
		b. exporting the python path

			Also run this from the same directory.
			
			```
			export PYTHONPATH=$PYTHONPATH:`pwd`:`pwd`/slim
			```
		c. modifying the setup.py file

			This file needs to be modified, because some dependencies are not present on Google Cloud Ml, and they need to be added. I copied the changed setup.py file into files_for_gcloud, as setup.py. Make sure that the setup.py file looks like that

		d. Modifying the config.yml file in the examples/configs  directory to use only 1 worker.

		e. running setup.py : 
			From the same directory as above do :
			
			```
			python setup.py && sdist
			```

		f. running setup.py from the ./slim directory.
		   Go to the ./slim directory and do :
		   
		   ```
		   python setup.py && sdist 
		   ```

		   * Note there is nothing to change in this setup.py file.

		   *If you ever get the error, no module called object_detection it is necessary to export the python path.

3. Downloading additional packages and files
	a. Pretrained Model
	The only model that worked was the faster_rcnn_resnet101_pets
	Download this model from a link on this page at: https://github.com/tensorflow/models/blob/master/research/object_detection/g3doc/running_pets.md

	Then untar it. Three files are of interest to us. The .data, .meta and .index files. The use of these files is further described in step 4.
	
	b. Pycocotools.tar.gz from this link : https://storage.googleapis.com/object-detection-dogfood/data/pycocotools-2.0.tar.gz
	
	After downloading , it can be placed anywhere, its path just has to be provided at the eval step.

4. Google Cloud Ml setup
		
		Cloud ML needs you to add a credit card(international). 

		After that you can use it.
		
		Create A Storage bucket, and inside it create three folders
		
		a.data
		b.train
		c.eval
		
		The address of the bucket is referred to like : gs://bucket-name
		
		Inside the data-folder, we need to upload the following files:

		1.label_map.pbtxt
			=> refer to the file "nail_label_map.pbtxt" in the files_for_gcloud/data_nail folder.
			=> this file has to just carry the label name and a corresponding integer id for that label.
		2.my_configuration_file.config
			=> refer to the file "neural_net.config" in the files_for_gcloud/data_nail folder. 
			=> Inside this file, we have to replace the addresses of several folders, with the addresses that correspond to our storage bucket.
			=> 
		3.training.record
			=> this is the tfrecord file generated for the training images. It is described in more detail below.
		4.test.record
			=> same as above, but for test images.
		5.the model files downloaded in step 3.
			=> 3 files have to be uploaded for the model. (.data, .index, and .meta)

		At the end my folder in the google cloud storage bucket looked like this (before starting training):



5. LabelImg setup and use
	Clone repository : https://github.com/tzutalin/labelImg.git
	This is the software to mark the bounding boxes on the images.
	Follow the instructions mentioned in the github page.
	Then launch the program by calling python labelimg.py
	There may be issues with qt, but you will have to solve these, I don't remember what I did.

	Thereafter, open the directory which has all your images, and begin marking the bouding boxes. Choose a directory to save the resulting xml files. Also choose a label for the bounding boxes. Remember that these are the same labels that you will have to use all throughout the program, especially in .pbtxt
	
6. Converting xml -> csv
	After the xml files have been made, you need to convert them into csv format.
	For this purpose use the script files_for_gcloud/xml_to_csv.py
	The example of a command for that script is :
	
	```
	python xml_to_csv.py /home/bhargav/Pictures/path_to_xml_files_folder /home/bhargav/csv_file.csv
	```

	# the first argument is the path to the xml files created with label image, the second is the path and full name of the output csv file.
	# run this once for the test and once for the training images. So that you get two csv files.

7. Checking csv for image problems.
	We need to check that none of the bounding boxes we marked are going outside the main image. For this run the script :
	
	```
	ruby check_csv_height_width.rb /path_to_csv_file
	```

	It will throw an error if there is anythign wrong with the coordiantes.

8. Converting csv -> tfrecord
	Now it is time to conver the csv to tfrecord files.
	Run the script:
	
	```
	python generate_tfrecord.py 	
	```

	See the file generate_tfrecord_command.txt for an example of what kind of arguments to pass.
	At the end you should have two tfrecord files , one for test and one for training.
	
9. Installing google-cloud-sdk:
	Download the google-cloud-sdk zip file and unzip it into any folder. Run the install.sh script. Set up your google account with it(the same one that you will be using with google cloud ml), and also it will ask you where to store the path. If you know where your $PATH is being read from, then specify that file. Otherwise, everytime you want to use the google-cloud-sdk you will first have to `source /path_location`.
	After installing, run bin/gcloud-init
	This will take your through deciding which account and project you want to use. Use the same project that you have configured for using with Cloud ML. 

10. local folder setup
	Model your local folder on the data_nail folder. You should have all the files similar to that. This folder we are going to copy en-bloc to our cloud bucket. The config file used(neural_net.config) there, is got from the location : 
	You will need to replace all the relevant paths (gs://) with all the paths to the folders in your bucket.

11. train command
	Refer to or just copy and paste, after making the relevant path changes from glcoud_training_command.txt. Run this from the models/research folder. It will block for a while, but then should say that the job is queued. 

12. eval command
	You can do this immediately or after while. Basically it keeps checking against the latest trained checkpoint. Just follow the gcloud_test_command.txt for this.

13. Visualization with tensorboard
	After you have done the gcloud init as mentioned earlier, launch tensorboard by using the following command:

	```
	tensorboard --logdir=gs://your_bucket/train --port 6006
	```

	Go to http://6006, and look for scalars.
	Sometimes you see nothing for a long time, if that is the case, cntrl+c to exit, then run this command:

	I don't remember right now, but in the screen in tensorboard, where it says readme/debug, go there and there is a command that they have given to check whether there are any event files at all. RUn that, it will take a long time, but will print a list of event files. After that, try again to run the tensorboard server. The "Scalars" are where you can see the loss graphs.


14. Downloading the trained model:
	
	Once the job has been running for some time, and you see that the loss graphs have tapered out. You need to download the latest checkpoint from the train directory in the bucket.
	The files to donwload are three (.data, .index and .meta) all for the latest checkpoint.
	Place these files in any folder of your choice.

15. Renaming the downloaded model
	
	Since the downloaded model is prefixed with checkpoint number details, just rename all the three files to be model.ckpt.whatever. Just keeping the name to model makes it simpler to operate in the front.


16. Using the model for predictions

	a. Generate the frozen graph from the download model:
	   Go to models/research/object_detection directory.
	   Now run the following command from there:

	   ```
	   python3 export_inference_graph.py \
       --input_type image_tensor \
       --pipeline_config_path training/ssd_mobilenet_v1_pets.config \
       --trained_checkpoint_prefix training/model.ckpt-10856 \
       --output_directory mac_n_cheese_inference_graph
       ```

       Here we have to make the pipeline_config_path, the name of the configurataion_file in your local folder.(neural_net.config)

       Here also note that the trained_checkpoint_prefix has to be just the prefix, so in our case if you renamed the model to just have "model", then you just have to write model.ckpt

       Set the output directory to whereever you want.
       It should generate several files into that directory, one of which will be .pb file.

    b. Use the model for prediction.
       In files_for_gcloud there is a file called detect.py. This is the file that I created from the python notebook file, that comes with the models/research/object_detection folder.
       Inside this file you need to change some paths:
       1. PATH_TO_CKPT : this should be the path to the generated .pb file
       2. PATH_TO_LABELS : the path in the local folder that contains the labesl you used (nail_label_map.pbtxt)
       3. PATH_TO_TEST_IMAGES_DIR : the path to the directory where you are going to place the images that you want to detect objects in. (This is not used actually)
       4. TEST_IMAGE_PATHS : an array containing the names of all the image files that you want to detect.

       Currently I could not get it to show the image with the bounding boxes plotted, instead I am writing the image with the overlaid bounding boxes, to a file called test.png. This is done on the penultimate line.

Folder Structure in analysis folder
-----------------------------------
b -> contains the images I had downloaded for Beau's lines

c -> same as above for clubbing

k -> same as above for koilonychia

nails -> same as above for nails

stage_for_gcloud ->
	
	training_images -> contains all the images from b + c + k + nails (may be missing some images, but these were the ones finally used.)

	training_xml_files -> all the xml files which I had generated for all the images in training_images.(these files were substantially modified wrt path, folder and name, in order to place them in this folder, but all that work need not be done if this has to be repeated, as it is best to specify the folder where the training images are in LabelImg and never change that later.)

	test_xml_files -> contains some xml files for images which were used as a test dataset. The folder, and path referred to in these xml_files is the training_images itself. Basically I did not make a seperate test_images directory, but rather kept all the images in the training_images directory.

	model_trained_from_gcloud -> downloaded the .data, .meta , .index files for the last checkpoint trained on gcloud into this folder, and later ran the script to generate the frozen graph also into this folder.

	test.record -> the final tfrecord built from the test_csv.csv file

	training.record -> the final tfrecord built from the training_csv.csv file

	training_csv.csv -> the csv file generated from the training_xml_files 

	test_csv.csv -> the final csv file generated from the test_xml_files

training_cropped_images ->

	b -> individual images of the fingernails with beau's lines
	k -> "" koilonychia
	c -> "" clubbing
	n -> "" nails
	misc -> empty

	Individual images generated by cropping the coordinates in the training_csv.csv files in analysis/stage_for_gcloud. Script used to do this is : files_for_gcloud/cropped_marked_images.rb

test_cropped_images ->

	Same as above but for test

files_for_gcloud ->
	
	data_nail ->

		This consists of the files that were uploaded to the data-nail folder in the bucket.
		This contains all the files mentioned in the Google Cloud Ml setup.
		The two csv files are not needed in the cloud bucket, but they were written there for the sake of being in one place.
		The neural_net.config was copied from the "****ADD THIS*****" folder, and paths were modified to reflect the paths in the bucket.

	check_csv_height_width.rb -> iterates the csv file provided and checks if the xmin||xmax is greater > width, and ymin||ymax > height. This needed to be done to eliminate any errors that happened while marking the images.

	crop_marked_images.rb -> crops the original images, using the coordinates stored in the csv files, and makes individual images out of the big image. These were written to the /analysis/test||training_cropped_images folders for the purposes of training the classification which did not work.

	export_model_command.txt -> this command is to be run models/research/object_detection directory. The arguments to the command are self explanatory. It is to be run , after you have downloaded the trained model from google cloud after training is complete. In our case the model_trained_from_gcloud contains the trained model download. And we also output the results of running this command to the same folder.

	gcloud_test_command -> this command is to be run from the models/research directory. It is to be run only after you have setup the 

	setup.py -> the modified setup.py file from models/research.

