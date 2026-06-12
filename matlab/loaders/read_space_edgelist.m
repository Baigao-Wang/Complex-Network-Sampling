function edges = read_space_edgelist(file_path, comment_char)
% 读取空白分隔的边表
% 默认跳过以 comment_char 开头的行

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

    if nargin >= 2 && ~isempty(comment_char)
        if startsWith(line, comment_char)
            continue;
        end
    end

    vals = sscanf(line, '%f');
    if numel(vals) >= 2
        edges(end+1, :) = vals(1:2)'; %#ok<AGROW>
    end
end

fclose(fid);

if isempty(edges)
    error('No valid edges read from file: %s', file_path);
end
end