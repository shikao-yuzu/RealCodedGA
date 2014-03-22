# -*- encoding: utf-8 -*-

# -----------------------------------------------------
#    多項式フィッティング
# -----------------------------------------------------
class PolynomialFit
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

	# パラメータのセットに対する評価関数の値(適合度)を求める
	def fitness(gene)
		fit = 0.0 # 適合度

		@dataX.zip(@dataY).each do |x, y|
			ye = 0.0 # フィッティングによる推定値

			# xの関数形は多項式
			# 多項式の次数は遺伝子(パラメータ)の数によって決まる
			gene.each_with_index do |p, i|
				ye += p * x ** i
			end

			fit += 0.5 * W * (y - ye) * (y - ye)
		end

		return fit
	end
end
