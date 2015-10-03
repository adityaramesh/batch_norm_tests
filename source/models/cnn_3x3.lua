require "torch"
require "nn"
require "cunn"

function get_model_info(opt)
	local model = nn.Sequential()

	-- Group 1: 32^2 -> 34^2 -> 32^2 -> 16^2
	model:add(nn.SpatialZeroPadding(1, 1, 1, 1))
	model:add(nn.SpatialConvolutionMM(3, 64, 3, 3))
	model:add(nn.ReLU())
	model:add(nn.SpatialZeroPadding(1, 1, 1, 1))
	model:add(nn.SpatialConvolutionMM(64, 64, 3, 3))
	model:add(nn.ReLU())
	model:add(nn.SpatialMaxPooling(2, 2, 2, 2))

	-- Group 2: 16^2 -> 18^2 -> 16^2 -> 8^2
	model:add(nn.SpatialZeroPadding(1, 1, 1, 1))
	model:add(nn.SpatialConvolutionMM(64, 128, 3, 3))
	model:add(nn.ReLU())
	model:add(nn.SpatialZeroPadding(1, 1, 1, 1))
	model:add(nn.SpatialConvolutionMM(128, 128, 3, 3))
	model:add(nn.ReLU())
	model:add(nn.SpatialMaxPooling(2, 2, 2, 2))

	-- Group 3: 8^2 -> 10^2 -> 8^2 -> 4^2
	model:add(nn.SpatialZeroPadding(1, 1, 1, 1))
	model:add(nn.SpatialConvolutionMM(128, 256, 3, 3))
	model:add(nn.ReLU())
	model:add(nn.SpatialZeroPadding(1, 1, 1, 1))
	model:add(nn.SpatialConvolutionMM(256, 256, 3, 3))
	model:add(nn.ReLU())
	model:add(nn.SpatialMaxPooling(2, 2, 2, 2))

	-- Group 4: 256 * 4^2 -> 1024
	local fc_inputs = 256 * 4 * 4
	model:add(nn.View(fc_inputs))
	model:add(nn.Dropout(0.7))
	model:add(nn.Linear(fc_inputs, 1024))
	model:add(nn.ReLU())

	-- Group 5: 1024 -> 10
	model:add(nn.Dropout(0.7))
	model:add(nn.Linear(1024, 10))
	model:add(nn.LogSoftMax())
	model:cuda()

	return {
		model = model,
		criterion = nn.ClassNLLCriterion():cuda()
	}
end
