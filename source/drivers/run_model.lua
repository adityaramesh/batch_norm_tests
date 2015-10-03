package.path = package.path .. ";./torch_utils/?.lua"

require "cutorch"
require "source/utility/run_model.lua"
require "torch_utils/sopt"

function options_func(cmd)
	model_io.default_options(cmd)
	cmd:option("-max_epochs", 80, "Number of epochs for which to train " ..
		"the current model.")
	cmd:option("-model_file", "source/models/cnn_3x3.lua", "Path to file " ..
		"that defines the model architecture.")
end

function get_task_info(opt)
        local pp_data_dir = "data/svhn/preprocessed"
        local train_file = paths.concat(pp_data_dir, "train_small.t7")
        local test_file = paths.concat(pp_data_dir, "test.t7")

	if opt.task ~= "evaluate" then
		return torch.load(train_file), torch.load(test_file)
	else
		return nil, torch.load(test_file)
	end
end

function get_model_info(opt)
        require(opt.model_file)
        return get_model_info(opt)
end

function get_train_info(opt)
        return {
                opt_state = {
                        learning_rate = sopt.constant(1),
			epsilon = 1e-11,
                        decay = sopt.constant(0.95),
                        momentum_type = sopt.none,
                },
                opt_method = AdaDeltaLMOptimizer,
                batch_size = 200,
		valid_epoch_ratio = 1,
		max_epochs = opt.max_epochs
        }
end

run(get_task_info, get_model_info, get_train_info, options_func)
