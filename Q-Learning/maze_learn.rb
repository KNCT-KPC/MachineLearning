# -*- coding: utf-8 -*-

# maze_learn.rb
# Q学習によって迷路を探索する様子をAAで出力するRubyスクリプト

# Q値表を初期化
def initialize_qtable(num_s, num_a)
	return Array.new(num_s){ Array.new(num_a, 0.0) } # Q値表を全0で初期化した配列を戻す
end

def initialize_maze(xsize, ysize)
	return Array.new(xsize){ Array.new(ysize, 0) }   # mazeを全0で初期化した配列を戻す
end

# 迷路の周りを壁で埋める
def  surround_by_walls(maze, xsize, ysize)
	for i in 0...xsize
	    maze[i][0]       = -1
    	maze[i][ysize-1] = -1
  	end
	for i in 0...ysize
    	maze[0][i]       = -1
    	maze[xsize-1][i] = -1
  	end
  	return maze
end

# 現在地を状態番号に変換
def xy_to_s(x, y, xsize)
  s = x + y * xsize   # 状態番号s
  return s
end

# ε-グリーディ法
def epsilon_greedy(epsilon, qtable, s, num_a)
	x = rand(100)
  	if x < epsilon*100 then
	    act = select_action(num_a)
  	else
	    act = select_best_action(qtable, s, num_a);
	end
	return act # 戻り値はq値表中の, 状態sの番号
end

# 最良となる行動を選択する
def select_best_action(qtable, s, num_a)
	imax = [0]           # Q値が最大となる行動の番号を詰め込む配列(行動[0]で仮の最大値の番号を代入)
  	max = qtable[s][0]   # Q値の最大値(行動[0]で仮の最大値を代入)
  	num_max = 1          # Q値の最大値の個数(行動[0]を代入しているので1個はある)
  	act = 0              # Q値が最大となる行動
 
	for i in 1...num_a
	    if max < qtable[s][i] then
	     	max = qtable[s][i]
    	  	imax[0] = i
      		num_max = 1
    	elsif max == qtable[s][i] then
      		imax.push(i)
      		num_max += 1
      	end
  	end

 	act = imax.sample
# 	print "act = ", act, "\n"
  	return act # 戻り値は, 状態sに於ける, Q値が最大となる行動の番号
end


# 行動を無作為に選択する
def select_action(num_a)
	return rand(num_a)
end

# 状態sでの最大のq値を返す
def max_qval(qtable, s, num_a)
	value = 0.0
	for i in 0...num_a
		if value < qtable[s][i] then
			value = qtable[s][i]
		end
	end
	return value
end

# Q値を更新する
def update_q(q, reward, qmax, epsilon, alpha, gamma)
	return (1 - alpha) * q + alpha * (reward + gamma * qmax)
end


# 移動(x座標, y座標の更新 & 次状態の決定)
def move(act, x, y, xsize)
	#print "act = ", act, ", x = ", $x, ", y = ", $y
	case act
	when 0  # 上に移動
		$x = x - 1
	when 1  # 右に移動
		$y = y + 1
	when 2  # 下に移動
		$x = x + 1
	when 3  # 左に移動
		$y = y - 1
	end

	#print "act = ", act, ", x = ", $x, ", y = ", $y

	sd = xy_to_s($x, $y, xsize)
	return sd   # 戻り値は次状態sd
end

# 画面出力
def print_maze(maze, xsize, ysize, s, qtable, num_a)
	for i in 0...xsize
	    for j in 0...ysize
	    	s_ij = xy_to_s(i, j, xsize) # 状態s_ij
      		if s_ij == s then
				print('M')
        	elsif maze[i][j] == -1 then
				print('#')
	      	elsif maze[i][j] == 0 then
				direction = select_best_action(qtable, s_ij, num_a)
				if qtable[s_ij][direction] != 0 then
					case direction
					when 0
						print('A')
					when 1
						print('>')
					when 2
						print('V')
					when 3
						print('<')
					end
				else
	  				print(' ')
				end
			elsif maze[i][j] == 10 then
				print('G')
			end
		end
	    puts ""
	end
end

# Q値表を出力
def print_qtable(qtable, num_s, num_a)
	for i in 0...num_s
		print 's = ', i
		for j in 0...num_a
			print "qtable[", i, "][", j, "] = ", qtable[i][j], " "
		end
		puts ""
	end
end


# 迷路の大きさ
xsize = 10
ysize = 9

# スタート位置
initial_x = 1
initial_y = 1

num_a = 4             # 行動の数 num_a (上下左右)
num_s = xsize * ysize # 状態の数 num_s (迷路のマスの数だけ)
reward = 10.0         # 報酬 reward

s  = 0   # 現状態 s
sd = 0   # 次状態 sd
a  = 0   # 行動   a 

qtable = initialize_qtable(num_s, num_a)  # Q値表
maze   = initialize_maze(xsize, ysize)  # 迷路生成（配列を全部0で初期化）

alpha = 0.5   # 学習率α
gamma = 0.9   # 割引率γ
epsilon = 0.1 # ε-グリーディ法の適用割合

episode = 300 # エピソード数
turn = 100    # ターン数

# 壁を配置
maze = surround_by_walls(maze, xsize, ysize)
maze[2][2] = -1
maze[2][6] = -1
maze[2][7] = -1
maze[3][2] = -1
maze[3][6] = -1
maze[6][3] = -1
maze[6][7] = -1
maze[7][3] = -1
maze[8][3] = -1

# ゴールを配置
maze[8][6] = 10

for i in 0...episode
	# スタート位置に配置
	$x = initial_x
	$y = initial_y

	# 状態sを初期化
    s = xy_to_s($x, $y, xsize)

    for j in 0...turn
		# 行動aを決定
		a = epsilon_greedy(epsilon, qtable, s, num_a)

		# 次状態sdを更新
      	sd = move(a, $x, $y, xsize)

		# 次状態と報酬を決定
		reward = maze[$x][$y]

		# 最大値を探索
		qmax = max_qval(qtable, sd, num_a)

		# 状態sと行動aに関するQ値を更新する
	    qtable[s][a] = update_q(qtable[s][a], reward, qmax, epsilon, alpha, gamma)

	    # 壁に埋まるかチーズを獲得したら探索終了
      	if reward != 0 then
			break
        end

       	# 次状態に遷移する(エージェントを配置)
       	s = xy_to_s($x, $y, xsize)
	end

    # 出力する
	if (i+1) % 10 == 0 then # 偶に結果を出力する
      #print_qtable(qtable, num_s, num_a);                   # Q値表全出力
      print i,"回目\n"
      print_maze(maze, xsize, ysize, s, qtable, num_a)       # 画面出力
      puts ""
    end
end

# 学習結果を出力する
$x = initial_x
$y = initial_y
s = xy_to_s($x, $y, xsize)
print_maze(maze, xsize, ysize, s, qtable, num_a)