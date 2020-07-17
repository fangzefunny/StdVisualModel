function [BOLD_target, param] = fakedataloader(prevPath,  target, dataset, roi,  model_idx, idx )

if strcmp( target, 'target' ) == 0

   fname = sprintf( 'simulation_data-%d_roi-%d_model-%d_sim-%d', dataset, roi, model_idx, idx );
   path = fullfile(prevPath, 'Data','fake', 'All stimulus classes', fname );
   load(path, 'simulation');
   param = simulation.param;
   BOLD_target = simulation.BOLD_pred;
   
end
 
end

