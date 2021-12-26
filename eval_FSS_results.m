% --------------------------------------------------------
% FS2K Evaluation
% Licensed under The MIT License [see LICENSE for details]
% Written by Peng Zheng
% MATLAB Version R2020b
% --------------------------------------------------------

clear, clc
close all


task = 'I2S';
gts_json_file = 'anno_test.json';
gts_json = jsondecode(fileread(gts_json_file));
if strcmp(task, 'I2S')
    methods = {
        'APDrawingGAN', 'FSGAN' ...
    };
else
    methods = { ...
        'Pix2pixHD' ...
    };
end
results_overall_scoot = [];
results_overall_ssim = [];
for idx_results_dir = 1 : length(methods)
    method = methods{idx_results_dir};
    disp(method);
    results_dir = strcat(task, '/', method);
    S = dir(results_dir);
    pred_files = {S.name};
    pred_files = pred_files(3:length(pred_files));

    scores_scoot = [];
    scores_ssim = [];

    % scoot
    scores_hair_w_scoot = [];
    scores_hair_wo_scoot = [];

    scores_hc_b_scoot = [];
    scores_hc_bl_scoot = [];
    scores_hc_r_scoot = [];
    scores_hc_g_scoot = [];

    scores_gender_m_scoot = [];
    scores_gender_f_scoot = [];

    scores_earring_w_scoot = [];
    scores_earring_wo_scoot = [];

    scores_smile_w_scoot = [];
    scores_smile_wo_scoot = [];

    scores_frontface_w_scoot = [];
    scores_frontface_wo_scoot = [];

    scores_style_1_scoot = [];
    scores_style_2_scoot = [];
    scores_style_3_scoot = [];

    % ssim
    scores_hair_w_ssim = [];
    scores_hair_wo_ssim = [];

    scores_hc_b_ssim = [];
    scores_hc_bl_ssim = [];
    scores_hc_r_ssim = [];
    scores_hc_g_ssim = [];

    scores_gender_m_ssim = [];
    scores_gender_f_ssim = [];

    scores_earring_w_ssim = [];
    scores_earring_wo_ssim = [];

    scores_smile_w_ssim = [];
    scores_smile_wo_ssim = [];

    scores_frontface_w_ssim = [];
    scores_frontface_wo_ssim = [];

    scores_style_1_ssim = [];
    scores_style_2_ssim = [];
    scores_style_3_ssim = [];


    for idx_image = 1 : length(gts_json)
        gt_json = gts_json(idx_image);
        if contains(gt_json.image_name, 'photo2')
            gt_fmt = '.png';
        else
            gt_fmt = '.jpg';
        end
        src_category_file_name = strsplit(strrep(gt_json.image_name, '\', '/'), '/');
        src_category = src_category_file_name{1};
        file_name = src_category_file_name{2};
        if contains(file_name, 'image')
            prefix = 'image';
        else if contains(file_name, 'sketch')
                prefix = 'sketch';
            end
        end
        file_name = file_name(length(prefix)+1:length(file_name));
        gt_path = strrep(strrep(strcat(fullfile('photo', src_category, strcat(prefix, file_name, gt_fmt))), 'photo', 'sketch'), 'image', 'sketch');
        if ~isfile(gt_path)
            gt_path = strrep(gt_path, '.jpg', '.png');
        end
        success_reading = 0;
        for idx_choose_pred = 1:length(pred_files)
            pred_file = pred_files{idx_choose_pred};
            if contains(pred_file, file_name)
                if mod(idx_image, 300) == 0
                    disp([num2str(idx_image), ' / ', num2str(length(gts_json)), ', ', pred_file, ' -- ', file_name]);
                end
                success_reading = 1;
                break
            end
        end
        if success_reading == 0
            disp(gt_path);
        end

        pred_path = strcat(fullfile(results_dir, pred_file));
        res = rgb2gray(imread(pred_path));
        gt = rgb2gray(imread(gt_path));
        [hei, wid] = size(gt);
        res = imresize(res, [hei, wid]);
        score_scoot_curr = scoot_measure(gt, res);
%         imshow([gt res]);

        score_ssim_curr = ssim(gt, res);
    %     disp([score_scoot_curr, score_ssim_curr]);
        scores_scoot = [scores_scoot; score_scoot_curr];
        scores_ssim = [scores_ssim; score_ssim_curr];
        if gt_json.hair == 0
            scores_hair_w_scoot = [scores_hair_w_scoot; score_scoot_curr];
            scores_hair_w_ssim= [scores_hair_w_ssim; score_ssim_curr];
        else
            scores_hair_wo_scoot = [scores_hair_wo_scoot; score_scoot_curr];
            scores_hair_wo_ssim= [scores_hair_wo_ssim; score_ssim_curr];
        end

        if gt_json.hair_color == 0
            scores_hc_b_scoot = [scores_hc_b_scoot; score_scoot_curr];
            scores_hc_b_ssim = [scores_hc_b_ssim; score_ssim_curr];
        else if gt_json.hair_color == 1
            scores_hc_bl_scoot = [scores_hc_bl_scoot; score_scoot_curr];
            scores_hc_bl_ssim = [scores_hc_bl_ssim; score_ssim_curr];
        else if gt_json.hair_color == 2
            scores_hc_r_scoot = [scores_hc_r_scoot; score_scoot_curr];
            scores_hc_r_ssim = [scores_hc_r_ssim; score_ssim_curr];
        else if gt_json.hair_color == 3
            scores_hc_g_scoot = [scores_hc_g_scoot; score_scoot_curr];
            scores_hc_g_ssim = [scores_hc_g_ssim; score_ssim_curr];
            end
            end
            end
        end

        if gt_json.gender == 0
            scores_gender_m_scoot = [scores_gender_m_scoot; score_scoot_curr];
            scores_gender_m_ssim = [scores_gender_m_ssim; score_ssim_curr];
        else if gt_json.gender == 1
            scores_gender_f_scoot = [scores_gender_f_scoot; score_scoot_curr];
            scores_gender_f_ssim = [scores_gender_f_ssim; score_ssim_curr];
            end
        end

        if gt_json.earring == 0
            scores_earring_w_scoot = [scores_earring_w_scoot; score_scoot_curr];
            scores_earring_w_ssim = [scores_earring_w_ssim; score_ssim_curr];
        else if gt_json.earring == 1
            scores_earring_wo_scoot = [scores_earring_wo_scoot; score_scoot_curr];
            scores_earring_wo_ssim = [scores_earring_wo_ssim; score_ssim_curr];
            end
        end

        if gt_json.smile == 0
            scores_smile_w_scoot = [scores_smile_w_scoot; score_scoot_curr];
            scores_smile_w_ssim = [scores_smile_w_ssim; score_ssim_curr];
        else if gt_json.smile == 1
            scores_smile_wo_scoot = [scores_smile_wo_scoot; score_scoot_curr];
            scores_smile_wo_ssim = [scores_smile_wo_ssim; score_ssim_curr];
            end
        end

        if gt_json.frontal_face == 0
            scores_frontface_w_scoot = [scores_frontface_w_scoot; score_scoot_curr];
            scores_frontface_w_ssim = [scores_frontface_w_ssim; score_ssim_curr];
        else if gt_json.frontal_face == 1
            scores_frontface_wo_scoot = [scores_frontface_wo_scoot; score_scoot_curr];
            scores_frontface_wo_ssim = [scores_frontface_wo_ssim; score_ssim_curr];
            end
        end

        if gt_json.style == 0
            scores_style_1_scoot = [scores_style_1_scoot; score_scoot_curr];
            scores_style_1_ssim = [scores_style_1_ssim; score_ssim_curr];
        else if gt_json.style== 1
            scores_style_2_scoot = [scores_style_2_scoot; score_scoot_curr];
            scores_style_2_ssim = [scores_style_2_ssim; score_ssim_curr];
        else if gt_json.style== 2
            scores_style_3_scoot = [scores_style_3_scoot; score_scoot_curr];
            scores_style_3_ssim = [scores_style_3_ssim; score_ssim_curr];
            end
            end
        end

    end

    score_scoot = mean(scores_scoot);
    score_ssim = mean(scores_ssim);

    scores_scoot_lst = [ ...
        score_scoot, ...
        mean(scores_hair_w_scoot), mean(scores_hair_wo_scoot), mean(scores_hc_b_scoot), mean(scores_hc_bl_scoot), mean(scores_hc_r_scoot), mean(scores_hc_g_scoot) ...
        mean(scores_gender_m_scoot), mean(scores_gender_f_scoot), mean(scores_earring_w_scoot), mean(scores_earring_wo_scoot), ...
        mean(scores_smile_w_scoot), mean(scores_smile_wo_scoot), mean(scores_frontface_w_scoot), mean(scores_frontface_wo_scoot), ...
        mean(scores_style_1_scoot), mean(scores_style_2_scoot), mean(scores_style_3_scoot) ...
    ];
    scores_ssim_lst = [ ...
        score_ssim, ...
        mean(scores_hair_w_ssim), mean(scores_hair_wo_ssim), mean(scores_hc_b_ssim), mean(scores_hc_bl_ssim), mean(scores_hc_r_ssim), mean(scores_hc_g_ssim) ...
        mean(scores_gender_m_ssim), mean(scores_gender_f_ssim), mean(scores_earring_w_ssim), mean(scores_earring_wo_ssim), ...
        mean(scores_smile_w_ssim), mean(scores_smile_wo_ssim), mean(scores_frontface_w_ssim), mean(scores_frontface_wo_ssim), ...
        mean(scores_style_1_ssim), mean(scores_style_2_ssim), mean(scores_style_3_ssim) ...
    ];
    results_overall_scoot = [results_overall_scoot; scores_scoot_lst];
    results_overall_ssim = [results_overall_ssim; scores_ssim_lst];
    method, score_scoot, score_ssim
end
xlsx_file = strcat('0results_', task, '.xlsx');
if isfile(xlsx_file)
    delete(xlsx_file);
end
writematrix(results_overall_scoot, xlsx_file, 'Sheet', 'scoot');
writematrix(results_overall_ssim, xlsx_file, 'Sheet', 'ssim');
results_overall_scoot
results_overall_ssim
