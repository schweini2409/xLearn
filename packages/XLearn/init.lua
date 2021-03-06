----------------------------------
-- Import all sorts of packages
----------------------------------

-- lua libs
require 'nn'
require 'torch'
require 'image'
require 'gfx'
require 'os'
require 'math'
require 'paths'
require 'ffmpeg'
require 'inline'

-- compiled code
require 'libXLearn'

if not XLearn then
   -- create XLearn table just for registering it
   XLearn = {}

   -- Helpers
   torch.include('XLearn', 'core.lua')
   torch.include('XLearn', 'toolBox.lua')
   torch.include('XLearn', 'OptionParser.lua')
   torch.include('XLearn', 'xPrompt.lua')
   torch.include('XLearn', 'imageBox.lua')
   torch.include('XLearn', 'table.lua')
   torch.include('XLearn', 'Displayer.lua')
   torch.include('XLearn', 'DataSet.lua')
   torch.include('XLearn', 'DataSetLabelMe.lua')
   torch.include('XLearn', 'DataList.lua')
   torch.include('XLearn', 'UnsupDataSet.lua')
   torch.include('XLearn', 'VideoDataSet.lua')

   -- nn.Deciders
   torch.include('XLearn', 'Decider.lua')
   torch.include('XLearn', 'ParzenDecider.lua')

   -- nn.Trainers
   torch.include('XLearn', 'Trainer.lua')
   torch.include('XLearn', 'AutoEncoderTrainer.lua')
   torch.include('XLearn', 'StochasticTrainer.lua')
   torch.include('XLearn', 'StochasticHessianTrainer.lua')
   torch.include('XLearn', 'ConfusionMatrix.lua')

   -- nn.Containers
   torch.include('XLearn', 'SequentialHessian.lua')

   torch.include('XLearn', 'Fovea.lua')

   -- nn.Modules
   torch.include('XLearn', 'AbsModule.lua')
   torch.include('XLearn', 'AbsModuleHessian.lua')
   torch.include('XLearn', 'RecursiveFovea.lua')
   torch.include('XLearn', 'RecursiveFoveaHessian.lua')
   torch.include('XLearn', 'SpatialConvolutionTable.lua')
   torch.include('XLearn', 'SpatialConvolutionTableHessian.lua')
   torch.include('XLearn', 'SpatialMaxPooling.lua')
   torch.include('XLearn', 'SpatialLinear.lua')
   torch.include('XLearn', 'SpatialFovea.lua')
   torch.include('XLearn', 'SpatialLinearHessian.lua')
   torch.include('XLearn', 'SpatialSubSamplingHessian.lua')
   torch.include('XLearn', 'SpatialReSampling.lua')
   torch.include('XLearn', 'SpatialUpSampling.lua')
   torch.include('XLearn', 'SpatialLogSoftMax.lua')
   torch.include('XLearn', 'GaborLayer.lua')
   torch.include('XLearn', 'ImageTransform.lua')
   torch.include('XLearn', 'ImageRescale.lua')
   torch.include('XLearn', 'ImageSource.lua')
   torch.include('XLearn', 'CAddTable.lua')
   torch.include('XLearn', 'CSubTable.lua')
   torch.include('XLearn', 'CMulTable.lua')
   torch.include('XLearn', 'CDivTable.lua')
   torch.include('XLearn', 'Power.lua')
   torch.include('XLearn', 'Square.lua')
   torch.include('XLearn', 'Sqrt.lua')
   torch.include('XLearn', 'CCSub.lua')
   torch.include('XLearn', 'CCAdd.lua')
   torch.include('XLearn', 'TanhHessian.lua')
   torch.include('XLearn', 'Threshold.lua')
   torch.include('XLearn', 'LocalGraph.lua')
   torch.include('XLearn', 'Mult.lua')
   torch.include('XLearn', 'Replicate.lua')
   torch.include('XLearn', 'ContrastNormalization.lua')
   torch.include('XLearn', 'LocalNorm.lua')
   torch.include('XLearn', 'LocalNorm_hardware.lua')
   torch.include('XLearn', 'LocalConnected.lua')
   torch.include('XLearn', 'SpatialPadding.lua')
   torch.include('XLearn', 'SpatialPaddingHessian.lua')
   torch.include('XLearn', 'LcEncoder.lua')
   torch.include('XLearn', 'LcDecoder.lua')
   torch.include('XLearn', 'Profiler.lua')
   torch.include('XLearn', 'PyramidPacker.lua')
   torch.include('XLearn', 'PyramidUnPacker.lua')

   -- nn.Modules, criterions
   torch.include('XLearn', 'EdgeCriterion.lua')
   torch.include('XLearn', 'SparseCriterion.lua')
   torch.include('XLearn', 'MalisCriterion.lua')
   torch.include('XLearn', 'MSECriterionHessian.lua')
   torch.include('XLearn', 'NllCriterion.lua')
   torch.include('XLearn', 'DrLimCriterion.lua')
   torch.include('XLearn', 'SuperCriterion.lua')
   torch.include('XLearn', 'SpatialMSECriterion.lua')
   torch.include('XLearn', 'SpatialNLLCriterion.lua')
end

return XLearn
