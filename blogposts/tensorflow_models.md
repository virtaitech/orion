# TensorFlow 使用Orion vGPU

在我们的[Quick Start](../doc/quick-start)中的各个场景均以TensorFlow 1.12作为示例：

* 在[Docker容器场景](../doc/quick-start/container.md)，我们展示了使用一块Orion vGPU，在Juypter Notebook中使用TensorFlow Eager Execution模式训练[pix2pix模型](https://github.com/tensorflow/tensorflow/blob/r1.12/tensorflow/contrib/eager/python/examples/pix2pix/pix2pix_eager.ipynb)
* 在[KVM虚拟机场景](../doc/quick-start/kvm.md)，我们展示了使用两块Orion vGPU，训练TensorFlow官方[CIFAR 10 Estimator](https://github.com/tensorflow/models/tree/r1.12.0/tutorials/image/cifar10_estimator)例子
* 在[Remote RDMA场景](../doc/quick-start/remote_rdma.md)，我们展示了使用两块Orion vGPU，通过[TensorFlow Benchmarks](https://github.com/tensorflow/benchmarks/tree/cnn_tf_v1.12_compatible/scripts/tf_cnn_benchmarks)，在Imagenet数据集上训练inception3模型。

读者在阅读Quick Start后，应该对于如何在TensorFlow框架下使用Orion vGPU加速模型训练与推理有了直观的认识。

因此，本文将不再提供step by step的使用范例，而是总结我们对TensorFlow模型的支持情况，并列举出经过我们大量测试的TensorFlow模型。

## 支持情况
Orion vGPU软件对TensorFlow 1.8 - 1.4, TensorFlow 2.0 版本提供深度支持。

其余TensorFlow模型均能正确高效地使用位于多物理GPU上的多块Orion vGPU进行训练和推理。

下面，我们列举出一部分Orion vGPU软件所支持的，经过大量测试的TensorFlow模型。

## [TensorFlow官方教程例子](https://www.tensorflow.org/tutorials)

Orion vGPU软件对TensorFlow官方教程中的例子提供全面的支持。下面，我们列举一部分例子，用户可以在自己的环境中部署Orion vGPU软件运行这些模型。

由于许多教程是以Juypter Notebook的形式提供的，用户可以参考Quick Start中[Docker容器](../doc/quick-start/container.md)章节在容器/KVM虚拟机/裸机上运行Jupyter Notebook。

* [DCGAN](https://github.com/tensorflow/tensorflow/blob/r1.12/tensorflow/contrib/eager/python/examples/generative_examples/dcgan.ipynb) 在MNIST数据集上训练模型以生成手写数字
* [Convolutional VAE](https://github.com/tensorflow/tensorflow/blob/r1.12/tensorflow/contrib/eager/python/examples/generative_examples/dcgan.ipynb) 在MNIST数据集上训练模型以生成手写数字
* [pix2pix](https://github.com/tensorflow/tensorflow/blob/r1.12/tensorflow/contrib/eager/python/examples/pix2pix/pix2pix_eager.ipynb) 在CMP Facade数据集上训练condition GAN以实现图片到图片的生成
* [Neural Style Transfer](https://github.com/tensorflow/models/blob/r1.12.0/research/nst_blogpost/4_Neural_Style_Transfer_with_Eager_Execution.ipynb) Finetune VGG19模型以实现图片风格迁移
* [Image Segmentation](https://github.com/tensorflow/models/blob/r1.12.0/samples/outreach/blogs/segmentation_blogpost/image_segmentation.ipynb) 在Kaggle Carvana数据集上训练U-Net进行图像分割
* [CIFAR10 Estimator](https://github.com/tensorflow/models/tree/r1.12.0/tutorials/image/cifar10_estimator): 在CIFAR10数据集上使用TF Estimator API训练CNN模型
* [Neural Translation with Attention](https://github.com/tensorflow/tensorflow/blob/r1.12/tensorflow/contrib/eager/python/examples/nmt_with_attention/nmt_with_attention.ipynb) 训练含有Attention机制的seq2seq模型，实现西班牙语到英语的翻译
* [Image Captioning with Attention](https://github.com/tensorflow/tensorflow/blob/r1.12/tensorflow/contrib/eager/python/examples/generative_examples/image_captioning_with_attention.ipynb) 在MSCOCO2014数据集上训练带有Attention机制的Image Caption模型
* [LSTM PTB](https://www.tensorflow.org/tutorials/sequences/recurrent) 根据论文["RECURRENT NEURAL NETWORK REGULARIZATION"](https://arxiv.org/abs/1409.2329)的内容，在PTB数据集上训练LSTM网络
* [Quick, Draw!](https://www.tensorflow.org/tutorials/sequences/recurrent_quickdraw) 在Quick, Draw!数据集的一个子集上，训练多层LSTM-CNN网络以识别涂鸦。

    注意，教程上运行模型训练时的命令参数不完整，在处理完TFRecord数据后，用户可以用下述命令使用cuDNN LSTM cell进行模型训练，共1000000步。

    ```bash
    python3 train_model.py \
        --training_data rnn_tutorial_data/training.tfrecord-?????-of-????? \
        --eval_data rnn_tutorial_data/eval.tfrecord-?????-of-????? \
        --model_dir /tmp/quickdraw_model/ \
        --cell_type cudnn_lstm \
        --classes_file rnn_tutorial_data/training.tfrecord.classes \
        --steps 1000000
    ```

    其间，训练过程不会输出到屏幕，用户需要使用TensorBoard监视训练过程：

    ```bash
    tensorboard --logdir /tmp/quickdraw_model
    ```

* [Simple Audio Recognition](https://www.tensorflow.org/tutorials/sequences/audio_recognition) 在[Speech Command数据集](https://storage.cloud.google.com/download.tensorflow.org/data/speech_commands_v0.02.tar.gz)上训练模型以识别简单语音命令。

## [TensorFlow 官方CNN Benchmarks](https://github.com/tensorflow/benchmarks/tree/cnn_tf_v1.12_compatible/scripts/tf_cnn_benchmarks)

在Quick Start的[远程RDMA](../doc/quick-start/remote_rdma.md#run-benchmarks)章节，我们展示了如何在没有GPU的节点上通过Orion vGPU软件，使用远程节点上的物理GPU运行TensorFlow CNN Benchmarks进行CNN模型训练。

具体地，我们展示了使用Benchmark生成的随机数据（synthetic data），以及转换为TFRecord格式的真实Imagenet数据训练inception3模型。我们使用两块Orion vGPU，每块Orion vGPU显存设置为15500MB （`ORION_GMEM=15500`），因此位于远程节点的两块显存均为16GB的Telsa V100计算卡上。

除了这个例子以外，我们针对各种不同场景、参数设置进行了大量正确性、稳定性和性能测试：

* VGG16, Resnet50, Resnet152, Inception_v3等CNN模型
* 裸机/容器/KVM虚拟机内在RDMA模式下使用远程节点物理GPU，以及容器/KVM虚拟机在共享内存模式下使用本地节点物理GPU
* 使用单张/多张Orion vGPU，多张Orion vGPU可以位于同一块物理GPU上，也可以位于多块物理GPU上
* TensorFlow Datasets的不同数据加载模式，例如打开/关闭prefetching，等

每种设置下，我们都用真实Imagenet数据训练模型，达到与native环境下TF使用本地物理GPU非常接近的性能（imgs/sec）。此外，我们对比了使用物理GPU和使用Orion vGPU时的训练效果，包括Loss下降速度，以及top-1、top-5训练精度，验证这两种情况下效果高度一致（训练过程本身存在随机性）。

对于Inference （evaluation）模式，我们从同样的模型checkpoints加载模型权重，对比使用本地物理GPU和使用Orion vGPU时的测试结果，包括测试集上的top-1和top-5精度，验证两种情况下结果**完全一致**。

## 更多的TensorFlow官方模型

* [BERT](https://github.com/google-research/bert) 使用Orion vGPU对BERT-Base模型在Microsoft Research Paraphase Corpus (MRPC)语料集上，或者在SQuAD 1.1任务数据集上进行finetuning。
* [Transformer](https://github.com/tensorflow/models/tree/r1.12.0/official/transformer) 使用Orion vGPU训练模型，实现英语到德语的翻译。

## [TensorFlow Research模型](https://github.com/tensorflow/models/tree/r1.12.0/research)



值得注意的是，此repo中的模型代码均基于Python 2.7环境，因此建议用户使用Python 2.7版本的镜像：

```bash
git pull virtaitech/orion-client:cu9.0-tf1.12-py2
```

或者在KVM虚拟机、裸物理机上配置好Python 2.7环境，然后安装TensorFlow 1.12 GPU版本，

```bash
apt install python-dev python-pip
pip install tensorflow-gpu==1.12.0
```

再根据[Quick Start](../doc/quick-start)中相应章节配置好Orion Client运行时。

如果用户一定要在Python 3环境中运行TensorFlow Research Models，几乎每个模型都需要改动部分代码以实现Python代码的兼容。

下面，我们列举部分兼容TensorFlow 1.12版本的模型。

* [TensorFlow Object Detection API](https://github.com/tensorflow/models/tree/r1.12.0/research/object_detection) 使用Orion vGPU训练Faster RCNN模型进行Object Detection，或者训练Mask RCNN模型进行Image Segmentation
* [Attention OCR](https://github.com/tensorflow/models/tree/r1.12.0/research/attention_ocr) 在FSNS数据集上训练Attention OCR模型
* [Cross-View Training](https://github.com/tensorflow/models/tree/r1.12.0/research/cvt_text) 根据论文["Semi-Supervised Sequence Modeling with Cross-View Training"](https://arxiv.org/abs/1809.08370)的内容，在CoNLL-2000数据集上利用GloVe词向量训练模型，完成sequence tagging和dependency parsing任务
* [DeepSpeech 2](https://github.com/tensorflow/models/tree/r1.12.0/research/deep_speech) 在[OpenSLR LibriSpeech Corpus](http://www.openslr.org/12/)上训练DeepSpeech2模型

* [KeypointNet](https://github.com/tensorflow/models/tree/r1.12.0/research/keypointnet) 训练论文["Discovery of Latent 3D Keypoints via End-to-end Geometric Reasoning"](https://arxiv.org/pdf/1807.03146.pdf)中的keypoint网络。
* [NeuralGPU](https://github.com/tensorflow/models/tree/r1.12.0/research/neural_gpu) 根据论文["Neural GPUs Learn Algorithms"](https://arxiv.org/abs/1511.08228)训练Neural GPU，执行sort, kvsort, mul, search等任务

* [vid2depth] 在KITTI数据集上训练论文["Unsupervised Learning of Depth and Ego-Motion from Monocular Video Using 3D Geometric Constraints"](https://arxiv.org/pdf/1802.05522.pdf) 中的模型，从摄像头拍摄的街景视频图片生成depth estimates。