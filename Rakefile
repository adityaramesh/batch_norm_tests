require "rake/clean"

task :exp_1_pp do
	color_spaces = ["nrgb", "yuv", "lab"]
	input_dir    = "data/svhn/raw/converted"
	output_dir   = "data/svhn/image_normalized"

	input_train  = color_spaces.map{|x| "#{input_dir}/train_small_#{x}.t7"}
	input_test   = color_spaces.map{|x| "#{input_dir}/test_#{x}.t7"}
	output_train = color_spaces.map{|x| "#{output_dir}/train_small_#{x}.t7"}
	output_test  = color_spaces.map{|x| "#{output_dir}/test_#{x}.t7"}
	stats        = color_spaces.map{|x| "#{output_dir}/stats_#{x}.t7"}

	sh "mkdir -p #{input_dir}"
	sh "mkdir -p #{output_dir}"

	input_train.zip(output_train, stats, input_test, output_test).each do |t|
		sh "th image_utils/scripts/normalize.lua " \
		        "-gcn image_std "                  \
			"-input #{t[0]} "                  \
			"-output #{t[1]} "                 \
			"-stats_output #{t[2]}"
		sh "th image_utils/scripts/normalize.lua " \
		        "-gcn image_std "                  \
			"-input #{t[3]} "                  \
			"-output #{t[4]} "                 \
			"-stats_input #{t[2]}"
	end
end

task :run_exp_1 do
	color_spaces = ["nrgb", "yuv", "lab"]
	data_dir     = "data/svhn/image_normalized"
	train_data   = color_spaces.map{|x| "#{data_dir}/train_small_#{x}.t7"}
	test_data    = color_spaces.map{|x| "#{data_dir}/test_#{x}.t7"}

	sh "mkdir -p models"

	sh "th source/drivers/experiment_1.lua "                           \
		"-model baseline "                                         \
		"-task replace "                                           \
		"-train_file data/svhn/raw/converted/train_small_nrgb.t7 " \
		"-test_file data/svhn/raw/converted/test_nrgb.t7 "

	color_spaces.zip(train_data, test_data).each do |t|
		sh "th source/drivers/experiment_1.lua " \
			"-model #{t[0]} "                \
			"-task replace "                 \
			"-train_file #{t[1]} "           \
			"-test_file #{t[2]}"
	end
end
