function edges = read_netscience_csv(file_path)

fid = fopen(file_path, 'r');
if fid == -1
    error('Cannot open file: %s', file_path);
end

edges = [];
line_num = 0;

while ~feof(fid)
    line = strtrim(fgetl(fid));
    line_num = line_num + 1;

    if ~ischar(line) || isempty(line)
        continue;
    end

    % 跳过注释/表头
    if startsWith(line, '#')
        continue;
    end

    parts = strsplit(line, ',');
    if numel(parts) >= 2
        u = str2double(strtrim(parts{1}));
        v = str2double(strtrim(parts{2}));

        if ~isnan(u) && ~isnan(v)
            edges(end+1, :) = [u, v]; %#ok<AGROW>
        end
    end
end

fclose(fid);

if isempty(edges)
    error('No valid edges read from file: %s', file_path);
end
end