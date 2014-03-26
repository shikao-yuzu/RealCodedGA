# -*- encoding: utf-8 -*-

# -----------------------------------------------------
#    個体群
# -----------------------------------------------------
class Population
	attr_reader :meanFit, :bestGene

	# sizePop : 個体数
	# sizeGene: 各個体の持つ遺伝子の数
	# geneMin : 遺伝子の下限
	# geneMax : 遺伝子の上限
	def initialize(sizePop, sizeGene, geneMin = 0.0, geneMax = 1.0)
		# 個体群
		@pop = Array.new(sizePop) { Array.new(sizeGene) { rand(geneMin...geneMax) } }

		# 各個体の適合度
		@fit = Array.new(sizePop, 0.0)

		# 個体群全体の適合度
		@meanFit = 0.0

		# 最良個体
		@bestGene = Array.new
	end

	def shuffle!
		@pop.shuffle!
	end

	def slice!(idx, len)
		@pop.slice!(idx, len)
	end

	def push(gene)
		@pop += gene
	end

	# 個体群の適合度を計算する
	def calc_fit(eval)
		@pop.each_with_index do |gene, idx|
			@fit[idx] = eval.fitness(gene)
		end

		# 個体群全体の適合度の算出
		@meanFit = mean_fit()

		# 最良個体の算出
		@bestGene = best_fit()
	end

	def show(generation)
		printf("\n\n---------- Population [generation = #{generation}] ----------\n")
		printf("    i\t  fitness\tgene\n\n")

		@pop.zip(@fit).each_with_index do |zip, idx|
			gene = zip[0]
			f    = zip[1]

			printf("%5d\t|", idx)

			if generation > 0
				printf("%10.4f|", f)
			else
				print("\t|")
			end

			gene.each do |g|
				printf("%10.4f", g)
			end
			printf("\n")
		end

		printf("\n[mean fitness]\n%10.4f\n", meanFit) if generation > 0
	end


	private


	def mean_fit
		@fit.inject(0.0) { |sum, idx| sum += idx } / @fit.length
	end

	def best_fit
		best    = []
		maximum = 0.0

		@pop.zip(@fit).each do |gene, f|
			if f > maximum
				best    = gene
				maximum = f
			end
		end

		return best
	end
end


# -----------------------------------------------------
#    実数値GA
#     - 世代交代モデル: Minimal Generation Gap (MGG)
#     - 交叉方法: Simplex Crossover (SPX)
#    ※参考文献
#     - いまさら聞けない 計算力学の常識 第6話
# -----------------------------------------------------
class RealCodedGA
	# geneNum: 各染色体の遺伝子の数
	def initialize(geneNum)
		@m    = geneNum    # 各個体の遺伝子の数
		@nPOP = 15 * @m    # 初期集団に属する個体の数
		@nP   = @m + 1     # 交叉の対象となる親個体の数
		@nCH  = 10 * @m    # 交叉によって生成される子個体の数
	end

	# 初期世代を乱数で生成する
	def seed(geneMin = 0.0, geneMax = 1.0)
		@population = Population.new(@nPOP, @m, geneMin, geneMax)
		@population.show(0)
	end

	# 実数値GAの実行
	def run(eval, gen)
		# 交叉対象の選択
		parent = select(@population)

		# 交差
		child = crossover(parent)

		# 世代交代
		evolve(eval, parent, child)

		# 適合度の算出
		@population.calc_fit(eval)

		# 世代の表示
		@population.show(gen)

		return @population.meanFit, @population.bestGene
	end


	private


	# 親個体を個体群からランダムに選択する
	def select(pop)
		pop.shuffle!
		return pop.slice!(0, @nP)
	end

	# 交叉によって子個体を生成する
	def crossover(parent)
		child = Array.new
		@nCH.times do
			child << simplex_crossover(parent)
		end
		return child
	end

	# 世代交代を行う
	def evolve(eval, parent, child)
		# 「世代交代の候補」 = 「子個体」 + 「親個体からランダムに2個」
		parent.shuffle!
		candidate  = parent.slice!(0, 2)
		candidate += child

		# 世代交代の候補からエリートを選択する
		elite = select_elite(eval, candidate)

		# 世代交代の候補(エリートは除く)からルーレット選択を行う
		roulette = select_roulette(eval, candidate)

		# 親個体に戻す
		parent << elite
		parent << roulette

		# 次世代の集団を生成する
		@population.push(parent)
	end

	# シンプレックス交叉
	def simplex_crossover(parent)
		# 重心の計算
		g = Array.new(@m, 0.0)
		for i in 0..@m-1
			for k in 0..@nP-1
				g[i] += parent[k][i]
			end
		end
		g.map! { |x| x / @nP }
		
		z = Array.new(@nP) { Array.new(@m, 0.0) }
		for i in 0..@m-1
			for k in 0..@nP-1
				z[k][i] = g[i] + Math.sqrt(@m + 2) * (parent[k][i] - g[i])
			end
		end

		c = Array.new(@nP) { Array.new(@m, 0.0) }
		for i in 0..@m-1
			for k in 1..@nP-1
				c[k][i] = (z[k-1][i] - z[k][i] + c[k-1][i]) * rand(0.0..1.0) ** (1.0 / (1.0 + (k-1).to_f))
			end
		end

		gene = Array.new(@m, 0.0)
		for i in 0..@m-1
			gene[i] = z[@nP-1][i] + c[@nP-1][i]
		end

		return gene
	end

	# エリート(最良個体)選択
	def select_elite(eval, candidate)
		elite   = Array.new
		delIdx  = 0
		maximum = 0.0

		candidate.each_with_index do |gene, idx|
			fit = eval.fitness(gene)

			if fit > maximum
				elite   = gene
				maximum = fit
				delIdx  = idx
			end
		end

		candidate.delete_at(delIdx)

		return elite
	end

	# ルーレット選択
	# ※参考文献
	#  - Cによる探索プログラミング pp.212-218
	def select_roulette(eval, candidate)
		pselect = Array.new(candidate.length)

		candidate.each_with_index do |gene, idx|
			fit = eval.fitness(gene)

			if idx == 0
				pselect[idx] = fit
			else
				pselect[idx] = pselect[idx-1] + fit
			end
		end
		pselect.map! { |x| x / pselect[candidate.length-1] }

		r = rand(0.0..1.0)
		i = 0
		roulette = candidate[0]
		while r > pselect[i]
			roulette = candidate[i+1]
			i += 1
		end

		return roulette
	end
end
