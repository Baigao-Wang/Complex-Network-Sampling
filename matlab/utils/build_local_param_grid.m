function [numSeeds_list, Pc_list] = build_local_param_grid(best_numSeeds, best_Pc, cfg)

numSeeds_list = best_numSeeds + cfg.numSeeds_offsets;
numSeeds_list = round(numSeeds_list);
numSeeds_list = numSeeds_list(numSeeds_list >= 1);
numSeeds_list = unique(numSeeds_list, 'stable');

Pc_list = best_Pc + cfg.Pc_offsets;
Pc_list = Pc_list(Pc_list >= cfg.Pc_min & Pc_list <= cfg.Pc_max);
Pc_list = unique(round(Pc_list, 4), 'stable');

end