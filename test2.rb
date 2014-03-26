# -*- encoding: utf-8 -*-

require './real-coded_GA.rb'
require './evaluation_func.rb'

# 世代数の上限
GENERATION_MAX = 100

# 各個体の遺伝子の数
GENE_NUM = 1

# 初期世代の遺伝子の範囲
GENE_MIN = -10.0
GENE_MAX = 10.0

# 終了条件
THRESHOLD = 1.0


# テストデータ
eval = SolveEquation.new

# 実数値GA
ga = RealCodedGA.new(GENE_NUM)
ga.seed(GENE_MIN, GENE_MAX)

(1..GENERATION_MAX).each do |i|
	meanFit, bestGene = ga.run(eval, i)
	break if meanFit > THRESHOLD
end
