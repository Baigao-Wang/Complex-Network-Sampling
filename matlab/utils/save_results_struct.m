function save_results_struct(S, filepath)

save(filepath, 'S', '-v7.3');
fprintf('Results saved to: %s\n', filepath);

end