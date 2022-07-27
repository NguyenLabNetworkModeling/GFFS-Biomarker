%% Task Manager

[~,SheetNames]  = xlsfinfo('feature set list.xlsx');

switch jobcode


    case 'model_train'

        prompt = ['choose a model :  \n ' ...
            '(1) SVM \n ' ...
            '(2) ANN  \n ' ...
            '(3) RF  \n ' ...
            ''];
        xx = input(prompt);
        task.model = xx;

        % three pre-selected feature sets
        yy = readInput( SheetNames );
        task.feature = yy;

        workdir = strcat(rootwd,'\Model training');
        mkdir(workdir,'Outcome')
        addpath(genpath(workdir));

        data_pre_processing

        if xx == 1
            disp([' ==> [SVM] selected',newline])
            model_training_SVM
        elseif xx == 2
            disp([' ==> [ANN] selected',newline])
            model_training_ANN
        elseif xx == 3
            disp([' ==> [RF] selected',newline])
        end

        post_processing_confusion



    case 'model_valid'

        % (under construction)
        workdir = strcat(rootwd,'\Model validation');
        mkdir(workdir,'Outcome')
        addpath(genpath(workdir));

        prompt = ['choose a validation data:  \n ' ...
            '(1) rna-seq \n ' ...
            '(2) protein  \n ' ...
            '(3) maggie  \n'...
            ];

        xx = input(prompt);
        task.valid = xx;

        %         if xx == 1
        %             task.feature = 4;
        %             % (4) val_rnaseq
        %         elseif xx == 2
        %             task.feature = 5;
        %             % (5) val_protein
        %         elseif xx == 3
        %             task.feature = 6;
        %             % (6) val_maggie
        %         end

        % three pre-selected feature sets
        yy = readInput( SheetNames );
        task.feature = yy;



        % data pre-processing
        valid_pre_processing

        model_validation_gdsc




    case 'feature_select'

        workdir = strcat(rootwd,'\Feature selection');
        mkdir(workdir,'Outcome')
        addpath(genpath(workdir));

        prompt = ['choose a job :  \n ' ...
            '(1) calculation of IS \n ' ...
            '(2) Feature Selection  \n ' ...
            '(3) FRE/FFS/LIME/SHAPLEY \n ' ...
            ] ;
        mm = input(prompt);

        % three pre-selected feature sets
        % three pre-selected feature sets
        yy = readInput( SheetNames );
        task.feature = yy;

        % data pre-processing
        data_pre_processing

        if mm == 1
            disp([' ==> [calculation of IS] selected',newline])
            calculation_influence_score

        elseif mm == 2
            disp([' ==> [Feature Selection] selected',newline])
            feature_selection

        elseif mm == 3

        end




    case 'signaure_analy'



    case  'companion_marker'

        workdir = strcat(rootwd,'\Companion biomarker');
        mkdir(workdir,'Outcome')
        addpath(genpath(workdir));

        % add a dependant fold
        addpath(strcat(rootwd,'\Feature selection\Outcome'));

        prompt = ['choose a job :  \n ' ...
            '(1) run companion biomarkers \n ' ...
            '(2) validation biomarkers  \n'...
            ];
        xx = input(prompt);


        if xx == 1
            disp([' ==> [companion biomarkers] selected',newline])
            disp('note: SVM and FEAT16 presetted')

            companion_biomarkers
            % (for what?)

        elseif xx == 2

            prompt = ['marker type :  \n ' ...
                '(1) randome (n=16) \n ' ...
                '(2) signature (n=16)  \n'...
                ];

            marker_type = input(prompt);

            if marker_type == 1


                % three pre-selected feature sets
                yy = readInput( SheetNames );
                task.feature = yy;

            else marker_type == 2


                % three pre-selected feature sets
                yy = readInput( SheetNames );
                task.feature = yy;


            end

        % data pre-processing
        data_pre_processing

        validation_biomarker

        end




    case  'compact_marker'

        workdir = strcat(rootwd,'\Compact biomarker');
        mkdir(workdir,'Outcome')
        addpath(genpath(workdir));


        % add a dependant fold
        addpath(strcat(rootwd,'\companion biomarker\Outcome'));

        data_pre_processing

        compact_biomarker

        expression_signature


    case 'prepare_valid' % (8)

        workdir = strcat(rootwd,'\Model validation');
        mkdir(workdir,'Outcome')
        addpath(genpath(workdir));


        task.feature = 2;
        % (feature 16)

        data_pre_processing

        prepare_validation_data

    case 'myTest'            % (9)

        % three pre-selected feature sets
        yy = readInput( SheetNames );
        task.feature = yy;

        workdir = strcat(rootwd,'\MyTest');
        mkdir(workdir,'Outcome')
        addpath(genpath(workdir));

        data_pre_processing


end



