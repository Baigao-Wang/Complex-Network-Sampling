function A = generate_er_graph(N, p)
% 生成无向无权 ER 图邻接矩阵

if N <= 0 || p < 0 || p > 1
    error('Invalid ER parameters.');
end

R = rand(N);
A = triu(R < p, 1);
A = A + A.';
A = double(A > 0);

end