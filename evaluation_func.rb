# -*- encoding: utf-8 -*-

class EvaluationFunc
	# パラメータのセットに対する適合度を求める
	def fitness(gene)
		e = func(gene)
		return 1.0 / (1.0 + e.abs)
	end
end


# -----------------------------------------------------
#    多項式フィッティング
# -----------------------------------------------------
class PolynomialFitting < EvaluationFunc
	# 評価関数の重み
	W = 1.0

	def initialize
		@dataX = Array.new
		@dataY = Array.new
	end

	def push(x, y)
		@dataX.push(x)
		@dataY.push(y)
	end

	def show
		printf("\n---------- Data for Polynomial Fitting ----------\n")
		printf("    i\t      x         y   \n\n")

		@dataX.zip(@dataY).each_with_index do |data, idx|
			x = data[0]
			y = data[1]
			printf("%5d\t|%10.4f%10.4f\n", idx, x, y)
		end
	end

	# 評価関数
	def func(param)
		e = 0.0 # 評価関数

		@dataX.zip(@dataY).each do |x, y|
			ye = 0.0 # フィッティングによる推定値

			# xの関数形は多項式
			# 多項式の次数はパラメータの数によって決まる
			param.each_with_index do |p, i|
				ye += p * x ** i
			end

			e += 0.5 * W * (y - ye) * (y - ye)
		end

		return e
	end
end


# -----------------------------------------------------
#    関数:f(x) = x^2 - 2
# -----------------------------------------------------
class SolveEquation < EvaluationFunc
	# 評価関数
	def func(x)
		e = x[0] ** 2.0 - 2.0
	end
end
