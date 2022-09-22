# Dart Neural Network

Check out the live demo @ [https://nn.jakelanders.com](https://nn.jakelanders.com)

This is an experiment in implementing a dense neural network completely in Dart without the aid of any packages, computational or otherwise. This demo currently shows that this network is able to learn on the Mnist hand-written digit dataset, and can predict inputted digits with ~87% accuracy. The model does have some significant drawbacks, the digits are expected to be relatively in the center. When they are not, the model accuracy drops off significantly. But overall, the model does a good job at guessing the digits you pass it.

This project supports all platforms that Flutter runs, and the website is a Flutter web app running inside a docker container. The application has been tested on the following:
- MacOS
- iOS
- Web

## Implementation

### Summary

The following components have been implemented:

- Activation Functions:
    - ReLU
    - Sigmoid
    - Softmax
- Layers
    - Dense
- Loss Functions
    - Binary Crossentropy
    - Categorical Crossentropy
- Optimziers
    - Ada Grad
    - Adam
    - RMS Prop
    - SGD

### Vector Type

To make my life easier during the creation of the various components, a `Vector` type was created. This type is a wrapper around an array and allows for more complex functions, namely dot products and vector arithmetic. This class implements `Iterable`, making interacting with the type similar to how you would the native Flutter `List` type.

I made two implementations of the `Vector` abstract class, `Vector1` and `Vector2`. The implementation of the arithmetic functions, dot product, sum, etc. methods were heavily based on the python package `numpy.array` type. 

`Vector1` is a wrapper around a `List<num>` type, with some more helpful functions like `sum()`, `mean()`, `min()`, `max()`, `normalize()`, `abs()`, `exp()`, and `log()`.

`Vector2` is a wrapper around a `List<Vector1>` type, and gives some more complex functions in addition to what is seen in `Vector1`. Vector2 allows constructors of `numpy.eye` and `numpy.diagonal_flat`. This type also has a custom implementation of `toString()` to allow for better print format of the type. This is similar to how `numpy` does it.

Make sure to check out the vector source code to check all of the functions that were implemented here: `./lib/vector/`.

## Model

### Training

The model was trained on the Mnist dataset with some modifications. First, when reading from any mnnist dataset, the pixel code was loaded into a `NNImage` class wrapper that holds the pixel data, the image size, and the label. This class also has a method for randomizing the position, scale, angle, and background noise This is returned as `List<NNImage>`. 

The training dataset consisted of 60000 vanilla mnist images, 60000 randomized mnist images, and 800 self generated randomized written digits, resulting in a total size of 120,800 images.

### Testing

The testing dataset consisted of 10000 vanilla mnist images, 10000 randomized mnist images, and 200 self generated randomized written digits, resulting in a total size of 20,800 images.

The full training and testing code can be found at the end of `./lib/neural_network.dart`

### Network Shape

The network consists of 2 layers. The first of size [784, 200] to accept the input pixel data as a flat array. This layer used a ReLU activation function with a regularization L2 value of `5e-4`.

The second layer is of size [200, 10] to accept the output from the first layer and output confidence percentages of each digit from 0-9. This layer used a sigmoid activation function, so all of the output neurons add to 1.

The network used a Categorical Crossentropy loss function, and an adam optimizer with a learning rate of `0.005` and a decay of `5e-4`. The batch size was `128`. The full network details can be found at `./lib/models/mnist_metadata.json`.

### Saving and Loading

Model states are able to be saved and loaded using a custom arbitrary format I created when developing this functionality. When a network is saved, the weights and biases are all dumped into a json file, zipped, and stored in `./lib/models`. A summary is also generated to give a comprehensive summary on the network state, such as `date`, `dataset`, `accuracy`, `layers` and their `activation` function and parameters, the `batchSize`, the `lossFunction`, the `optimizer` and its arguments, and the `seed`. 

A model can be loaded from this file as well through one of the constructors, and can be used to predict inputs of the same shape the model was trained on.

## Flutter Demo

To show off the network code, Flutter was the natural choice to build a front-end with because the network was written in Dart.

The first view created was a basic drawing canvas implemented from scratch. The default canvas is `28x28` pixels with a pixel size of `10`, but this can be customized like is done when the screen size allows for a larger canvas. This view reports the pixel values every x milliseconds.

The model is loaded from a stored json file, the model of which was generated as described above. When the user draws a digit on the canvas, the pixel values are flattened and passed through the network to get the percentage likelihood of each respective output.

This code theoretically should run on all platforms, but has only been tested on MacOS, iOS, and Web.

## Drawbacks

The network does a decent job at guessing novel digits, but definitely has some drawbacks that need to be solved. The first is the network expected the images to be centered in the canvas.

If you draw a 1 outside the center, it will not detect it is a 1. I tried to get around this by randomizing the offset of each digit, but that did not seem to have an impact. Another solution could potentially be centering the drawn digits before passing through the network.

Another is the accuracy on the vanilla network is only around 95%. On the Mnist dataset this is not a great accuracy and the model parameters could definitely be tweaked to be better. Though at it's current state it is 'good enough'.

## Inspiration

Most of the conceptual ideas from how to implement the network comes from the amazing book by [Sentdex](https://www.youtube.com/channel/UCfzlCWGWYyIQ0aLC5w48gBQ) on Youtube, [Neural Networks from Scratch in Python](https://nnfs.io).

Another inspiration for this project came from a [Youtube video](https://www.youtube.com/watch?v=hfMk-kjRv4c) from [Sebastian Lague](https://www.youtube.com/c/SebastianLague) about his journey on implementing a neural network in C# with Unity. In particular, his idea on generating random noise in the Mnist dataset to improve the accuracy on non-dataset images got me through a block when my network was severely overfitting.

## Datasets

### Mnist

I pulled the csv formatted version of the Mnist dataset from: [https://www.kaggle.com/datasets/oddrationale/mnist-in-csv?resource=download](https://www.kaggle.com/datasets/oddrationale/mnist-in-csv?resource=download)

To improve the accuracy of the model, I added some random noise in the data by randomizing some parameters of the image: The `angle`, `offset`, `scale`, and some `random noise` was randomized per image and fed into the network in addition to the vanilla dataset, increasing the side from 60000 to 120000 training images. The same thing was done to the testing data.

Lastly, I created my own drawing program and wrote 10 of each of the 10 digits, and randomized each one 10 times to add an additional 1000 images into the dataset. I am not sure if this makes any noticable impact in the model learning, and the code for how I did that can be found in `./lib/views/create_dataset.dart`. 

### Spiral

A spiral dataset was used while developing the network. The code was pulled from: [https://gist.github.com/Sentdex/454cb20ec5acf0e76ee8ab8448e6266c](https://gist.github.com/Sentdex/454cb20ec5acf0e76ee8ab8448e6266c) and translated to dart by hand. You can define the number of points generated with `points`, the number of classes with `classes`, and the randomness of the spiral with `randomFactor`.

## Links

- [Live Demo](https://nn.jakelanders.com)
- [Neural Networks from Scratch](https://nnfs.io)
- [Sentdex on Youtube](https://www.youtube.com/channel/UCfzlCWGWYyIQ0aLC5w48gBQ)
- [Neural Networks from Scratch In X Github](https://github.com/Sentdex/NNfSiX)
- [Sebastian Lague on Youtube](https://www.youtube.com/c/SebastianLague)
- [Sebastian Lague video on neural networks](https://www.youtube.com/watch?v=hfMk-kjRv4c)
- [Mnist dataset](https://www.kaggle.com/datasets/oddrationale/mnist-in-csv?resource=download)
- [Spiral dataset code](https://gist.github.com/Sentdex/454cb20ec5acf0e76ee8ab8448e6266c)

