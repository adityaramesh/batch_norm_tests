require "rake/clean"

task :exp_1_pp do
	color_spaces = ["nrgb", "yuv", "lab"]
	input_dir    = "data/svhn/raw/converted"
	output_dir   = "data/svhn/image_std"

	input_train  = color_spaces.map{|x| "#{input_dir}/train_small_#{x}.t7"}
	input_test   = color_spaces.map{|x| "#{input_dir}/test_#{x}.t7"}
	output_train = color_spaces.map{|x| "#{output_dir}/train_small_#{x}.t7"}
	output_test  = color_spaces.map{|x| "#{output_dir}/test_#{x}.t7"}
	stats        = color_spaces.map{|x| "#{output_dir}/stats_#{x}.t7"}

	sh "mkdir -p #{input_dir}"
	sh "mkdir -p #{output_dir}"

	# We don't use LCN, because our objective is to test the effectiveness of
	# the image representation in each of the color spaces.

	input_train.zip(output_train, stats, input_test, output_test).each do |t|
		sh "th image_utils/scripts/normalize.lua " \
		        "-gcn image_std "                  \
			"-lcn none "                       \
			"-input #{t[0]} "                  \
			"-output #{t[1]} "                 \
			"-stats_output #{t[2]}"
		sh "th image_utils/scripts/normalize.lua " \
		        "-gcn image_std "                  \
			"-lcn none "                       \
			"-input #{t[3]} "                  \
			"-output #{t[4]} "                 \
			"-stats_input #{t[2]}"
	end
end

task :run_exp_1 do
	color_spaces = ["nrgb", "yuv", "lab"]
	data_dir     = "data/svhn/image_std"
	train_data   = color_spaces.map{|x| "#{data_dir}/train_small_#{x}.t7"}
	test_data    = color_spaces.map{|x| "#{data_dir}/test_#{x}.t7"}

	sh "mkdir -p models"

	sh "th source/drivers/experiment_1.lua "                           \
		"-model baseline "                                         \
		"-task replace "                                           \
		"-max_epochs 50 "                                          \
		"-train_file data/svhn/raw/converted/train_small_nrgb.t7 " \
		"-test_file data/svhn/raw/converted/test_nrgb.t7 "

	color_spaces.zip(train_data, test_data).each do |t|
		sh "th source/drivers/experiment_1.lua " \
			"-model #{t[0]} "                \
			"-task replace "                 \
			"-max_epochs 50 "                \
			"-train_file #{t[1]} "           \
			"-test_file #{t[2]}"
	end
end

task :exp_2_pp do
	sh "mkdir -p data/svhn/pixel_std"
	sh "mkdir -p data/svhn/image_pixel_std"

	sh "th image_utils/scripts/normalize.lua "                    \
		"-gcn pixel_std "                                     \
		"-lcn none "                                          \
		"-input data/svhn/raw/converted/train_small_nrgb.t7 " \
		"-output data/svhn/pixel_std/train_small_nrgb.t7 "    \
		"-stats_output data/svhn/pixel_std/nrgb_stats.t7 "

	sh "th image_utils/scripts/normalize.lua "                 \
		"-gcn pixel_std "                                  \
		"-lcn none "                                       \
		"-input data/svhn/raw/converted/test_nrgb.t7 "     \
		"-output data/svhn/pixel_std/test_nrgb.t7 "        \
		"-stats_input data/svhn/pixel_std/nrgb_stats.t7 "

	sh "th image_utils/scripts/normalize.lua "                       \
		"-gcn pixel_std "                                        \
		"-lcn none "                                             \
		"-input data/svhn/image_std/train_small_nrgb.t7 "        \
		"-output data/svhn/image_pixel_std/train_small_nrgb.t7 " \
		"-stats_output data/svhn/image_pixel_std/nrgb_stats.t7 "

	sh "th image_utils/scripts/normalize.lua "                      \
		"-gcn pixel_std "                                       \
		"-lcn none "                                            \
		"-input data/svhn/image_std/test_nrgb.t7 "              \
		"-output data/svhn/image_pixel_std/test_nrgb.t7 "       \
		"-stats_input data/svhn/image_pixel_std/nrgb_stats.t7 "
end

task :run_exp_2 do
	sh "mkdir -p models"

	sh "th source/drivers/experiment_1.lua "                       \
		"-model nrgb_pixel_std "                               \
		"-task replace "                                       \
		"-max_epochs 50 "                                      \
		"-train_file data/svhn/pixel_std/train_small_nrgb.t7 " \
		"-test_file data/svhn/pixel_std/test_nrgb.t7 "

	sh "th source/drivers/experiment_1.lua "                             \
		"-model nrgb_image_pixel_std "                               \
		"-task replace "                                             \
		"-max_epochs 50 "                                            \
		"-train_file data/svhn/image_pixel_std/train_small_nrgb.t7 " \
		"-test_file data/svhn/image_pixel_std/test_nrgb.t7 "
end

task :exp_3_pp do
	sh "mkdir -p data/svhn/lcn"

	# Generate data with LCN only, on all channels.

	sh "th image_utils/scripts/normalize.lua "                     \
		"-gcn none "                                           \
		"-lcn 123 "                                            \
		"-input data/svhn/raw/converted/train_small_nrgb.t7 "  \
		"-output data/svhn/lcn/train_small_nrgb_lcn.t7 "

	sh "th image_utils/scripts/normalize.lua "             \
		"-gcn none "                                   \
		"-lcn 123 "                                    \
		"-input data/svhn/raw/converted/test_nrgb.t7 " \
		"-output data/svhn/lcn/test_nrgb_lcn.t7 "

	# Generate data with LCN, on the color channels only.

	sh "th image_utils/scripts/normalize.lua "                    \
		"-gcn none "                                          \
		"-lcn 23 "                                            \
		"-input data/svhn/raw/converted/train_small_yuv.t7 "  \
		"-output data/svhn/lcn/train_small_yuv_lcn_color.t7 "

	sh "th image_utils/scripts/normalize.lua "             \
		"-gcn none "                                   \
		"-lcn 23 "                                     \
		"-input data/svhn/raw/converted/test_yuv.t7 "  \
		"-output data/svhn/lcn/test_yuv_lcn_color.t7 "

	sh "th image_utils/scripts/convert_color_space.lua "           \
		"-cs_src yuv "                                         \
		"-cs_dst nrgb "                                        \
		"-input data/svhn/lcn/train_small_yuv_lcn_color.t7 "   \
		"-output data/svhn/lcn/train_small_nrgb_lcn_color.t7 "

	sh "th image_utils/scripts/convert_color_space.lua "    \
		"-cs_src yuv "                                  \
		"-cs_dst nrgb "                                 \
		"-input data/svhn/lcn/test_yuv_lcn_color.t7 "   \
		"-output data/svhn/lcn/test_nrgb_lcn_color.t7 "

	sh "rm data/svhn/lcn/train_small_yuv_lcn_color.t7"
	sh "rm data/svhn/lcn/test_yuv_lcn_color.t7"

	# Generate data with GCN + LCN on all channels.

	sh "th image_utils/scripts/normalize.lua "                    \
		"-gcn image_std "                                     \
		"-lcn 123 "                                           \
		"-input data/svhn/raw/converted/train_small_nrgb.t7 " \
		"-output data/svhn/lcn/train_small_nrgb_gcn_lcn.t7 "  \
		"-stats_output data/svhn/lcn/nrgb_gcn_lcn_stats.t7 "

	sh "th image_utils/scripts/normalize.lua "                  \
		"-gcn image_std "                                   \
		"-lcn 123 "                                         \
		"-input data/svhn/raw/converted/test_nrgb.t7 "      \
		"-output data/svhn/lcn/test_nrgb_gcn_lcn.t7 "       \
		"-stats_input data/svhn/lcn/nrgb_gcn_lcn_stats.t7 "

	# Generate data with GCN + LCN only on the color channels. We want to
	# do LCN on the U and V channels only, and the GCN on the RGB channels.
	# Rather than do the conversions and preprocessing from scratch, we can
	# simply reuse the results of the previous preprocessing. Then all we
	# have to do is the GCN.

	sh "th image_utils/scripts/normalize.lua "                         \
		"-gcn image_std "                                          \
		"-lcn none "                                               \
		"-input data/svhn/lcn/train_small_nrgb_lcn_color.t7 "      \
		"-output data/svhn/lcn/train_small_nrgb_gcn_lcn_color.t7 "  \
		"-stats_output data/svhn/lcn/nrgb_gcn_lcn_color_stats.t7 "

	sh "th image_utils/scripts/normalize.lua "                        \
		"-gcn image_std "                                         \
		"-lcn none "                                              \
		"-input data/svhn/lcn/test_nrgb_lcn_color.t7 "            \
		"-output data/svhn/lcn/test_nrgb_gcn_lcn_color.t7 "       \
		"-stats_input data/svhn/lcn/nrgb_gcn_lcn_color_stats.t7 "
end

task :run_exp_3 do
	sh "mkdir -p models"

	sh "th source/drivers/experiment_1.lua "                     \
		"-model nrgb_lcn "                                   \
		"-task replace "                                     \
		"-max_epochs 50 "                                    \
		"-train_file data/svhn/lcn/train_small_nrgb_lcn.t7 " \
		"-test_file data/svhn/lcn/test_nrgb_lcn.t7 "

	sh "th source/drivers/experiment_1.lua "                           \
		"-model nrgb_lcn_color "                                   \
		"-task replace "                                           \
		"-max_epochs 50 "                                          \
		"-train_file data/svhn/lcn/train_small_nrgb_lcn_color.t7 " \
		"-test_file data/svhn/lcn/test_nrgb_lcn_color.t7 "

	sh "th source/drivers/experiment_1.lua "                         \
		"-model nrgb_gcn_lcn "                                   \
		"-task replace "                                         \
		"-max_epochs 50 "                                        \
		"-train_file data/svhn/lcn/train_small_nrgb_gcn_lcn.t7 " \
		"-test_file data/svhn/lcn/test_nrgb_gcn_lcn.t7 "

	sh "th source/drivers/experiment_1.lua "                               \
		"-model nrgb_gcn_lcn_color "                                   \
		"-task replace "                                               \
		"-max_epochs 50 "                                              \
		"-train_file data/svhn/lcn/train_small_nrgb_gcn_lcn_color.t7 " \
		"-test_file data/svhn/lcn/test_nrgb_gcn_lcn_color.t7 "
end

task :exp_4_pp do
	epsilon = [1e-1, 1e-3, 1e-5, 1e-7, 0]

	sh "mkdir -p data/svhn/whitened"

	sh "th image_utils/scripts/convert.lua "                   \
		"-input data/svhn/raw/original/train_small.t7 "    \
		"-output data/svhn/raw/original/train_small.hdf5 "

	sh "th image_utils/scripts/convert.lua "            \
		"-input data/svhn/raw/original/test.t7 "    \
		"-output data/svhn/raw/original/test.hdf5 "

	sh "th image_utils/scripts/convert.lua "                     \
		"-input data/svhn/lcn/train_small_nrgb_gcn_lcn.t7 "  \
		"-output data/svhn/lcn/train_small_nrgb_gcn_lcn.t7 "

	sh "th image_utils/scripts/convert.lua "             \
		"-input data/svhn/lcn/test_nrgb_gcn_lcn.t7 " \
		"-output data/svhn/lcn/test_nrgb_gcn_lcn.t7 "

	epsilon.each do |e|
		sh "python image_utils/scripts/whiten.py "                      \
			"-epsilon #{e} "                                        \
			"-input data/svhn/raw/original/train_small.hdf5 "       \
			"-output data/svhn/whitened/train_small_raw_#{e}.hdf5 " \
			"-stats_output data/svhn/whitened/raw_stats_#{e}.hdf5 "

		sh "python image_utils/scripts/whiten.py "                     \
			"-epsilon #{e} "                                       \
			"-input data/svhn/raw/original/test.hdf5 "             \
			"-output data/svhn/whitened/test_raw_#{e}.hdf5 "       \
			"-stats_input data/svhn/whitened/raw_stats_#{e}.hdf5 "

		sh "python image_utils/scripts/whiten.py "                     \
			"-epsilon #{e} "                                       \
			"-input data/svhn/lcn/train_small_nrgb_gcn_lcn.hdf5 "  \
			"-output data/svhn/whitened/train_small_pp_#{e}.hdf5 " \
			"-stats_output data/svhn/whitened/pp_stats_#{e}.hdf5 "

		sh "python image_utils/scripts/whiten.py "                    \
			"-epsilon #{e} "                                      \
			"-input data/svhn/lcn/test_nrgb_gcn_lcn.hdf5 "        \
			"-output data/svhn/whitened/test_pp_#{e}.hdf5 "       \
			"-stats_input data/svhn/whitened/pp_stats_#{e}.hdf5 "

		sh "image_utils/scripts/convert.lua "                          \
			"-input data/svhn/whitened/train_small_raw_#{e}.hdf5 " \
			"-output data/svhn/whitened/train_small_raw_#{e}.t7 "

		sh "image_utils/scripts/convert.lua "                   \
			"-input data/svhn/whitened/test_raw_#{e}.hdf5 " \
			"-output data/svhn/whitened/test_raw_#{e}.t7 "

		sh "image_utils/scripts/convert.lua "                         \
			"-input data/svhn/whitened/train_small_pp_#{e}.hdf5 " \
			"-output data/svhn/whitened/train_small_pp_#{e}.t7 "

		sh "image_utils/scripts/convert.lua "                  \
			"-input data/svhn/whitened/test_pp_#{e}.hdf5 " \
			"-output data/svhn/whitened/test_pp_#{e}.t7 "
	end
end
