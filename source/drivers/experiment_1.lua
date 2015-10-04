package.path = package.path .. ";./torch_utils/?.lua"
package.path = package.path .. ";./image_utils/?.lua"

require "cutorch"
require "torch_utils/sopt"
require "image_utils/image_utils"

function options_func(cmd)
	model_io.default_options(cmd)
	cmd:option("-train_file", "", "Path to file with training data.")
	cmd:option("-test_file", "", "Path to file with testing data.")
	cmd:option("-max_epochs", 80, "Number of epochs to train.")
	cmd:option("-valid_epoch_ratio", 5, "Number of training epochs per validation epoch.")
	cmd:option("-model_file", "source/models/cnn_5x5.lua", "Path to file that defines model architecture.")
end

function get_task_info(opt)
	local test_data = image_utils.load(opt.test_file)

	if opt.task ~= "evaluate" then
		return image_utils.load(opt.train_file), test_data
	end

	-- If the model is only being evaluated on the test set, then there is
	-- no need to load the training data.
	return nil, test_data
end

function load_model_info(opt)
	require(opt.model_file)
	return get_model_info(opt)
end

function get_train_info(opt)
	return {
		opt_state = {
			learning_rate = sopt.constant(1),
			epsilon = 1e-11,
			decay = sopt.constant(0.95),
			momentum_type = sopt.none
		},
		opt_method = AdaDeltaLMOptimizer,
		batch_size = 200,
		max_epochs = opt.max_epochs,
		valid_epoch_ratio = opt.valid_epoch_ratio
	}
end

image_utils.run_model(get_task_info, load_model_info, get_train_info, options_func)
