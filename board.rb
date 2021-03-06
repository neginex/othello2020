# coding: utf-8
 require "tk"

# マスの幅
SWIDTH = 70

# 盤の周囲のマージン
MARGIN = 20

# メッセージ表示領域の高さ
MHEIGHT = 80

# 盤に配置する石, 壁, 空白
BLACK = 1
WHITE = -1
EMPTY = 0
WALL = 2

# 石を打てる方向(2進数のビットフラグ)
NONE = 0
UPPER = 1
UPPER_LEFT=2
LEFT=4
LOWER_LEFT=8
LOWER=16
LOWER_RIGHT=32
RIGHT=64
UPPER_RIGHT=128

# 盤のサイズと手数の最大数
BOARDSIZE=8
MAXTURNS=60

# minmaxで探索する深さ
LIMIT = 2
# 残り手数がLIMIT2以下になったら最後まで読み取る
LIMIT2 = 6
# スコアの最大値
MAXSCORE = 10000

# 盤を表すクラスの定義
class Board
  # 盤を表す配列
  @rawBoard = nil
  # 石を打てる場所を格納する配列
  @movableDir = nil

  # 盤を(再)初期化
  def init
    @turns = 0
    @current_color = BLACK

    # 配列が未作成であれば作成する
    if @rawBoard == nil
      @rawBoard = Array.new(BOARDSIZE + 2).map{Array.new(BOARDSIZE + 2, EMPTY)}
    end
    if @movableDir == nil
      @movableDir = Array.new(BOARDSIZE + 2).map{Array.new(BOARDSIZE + 2, NONE)}
    end

    # @rawBoardを初期化, 周囲を壁（WALL)で囲む
    for x in 0..BOARDSIZE + 1 do
      for y in 0..BOARDSIZE + 1 do
        @rawBoard[x][y] = EMPTY
        if y == 0 or y == BOARDSIZE + 1 or x == 0 or x == BOARDSIZE + 1
          @rawBoard[x][y] = WALL
        end
      end
    end

    # 石を配置
    @rawBoard[4][4] = WHITE
    @rawBoard[5][5] = WHITE
    @rawBoard[4][5] = BLACK
    @rawBoard[5][4] = BLACK

    self.initMovable
  end
  # set a value of @movableDir
  def initMovable
    for x in 1..BOARDSIZE do
      for y in 1..BOARDSIZE do
        dir = self.checkMobility(x, y, @current_color)

        @movableDir[x][y] = dir
      end
    end
    puts dir
  end

  # check the direction that you can put a stone
  def checkMobility(x1, y1, color)
    # you cannnot if already exist
    if @rawBoard[x1][y1] != EMPTY
      return NONE
    end

    # initialize the direction "dir"
    dir = NONE

    # UP
    x = x1
    y = y1
    # if below is opposite color
    if @rawBoard[x][y-1] == -color
      # set y - 1 to y
      y = y - 1
      # go up til [x][y] => opposite color
      while (@rawBoard[x][y] == -color)
        y = y - 1
      end

      if @rawBoard[x][y] == color
        dir |= UPPER
      end
    end

    # DOWN
    x = x1
    y = y1
    if @rawBoard[x][y+1] == -color
      y = y + 1
      while (@rawBoard[x][y] == -color)
        y = y + 1
      end
      if @rawBoard[x][y] == color
        dir |= LOWER
      end
    end

    # LEFT
    x = x1
    y = y1

    if @rawBoard[x-1][y] == -color
      x = x - 1
      while (@rawBoard[x][y] == -color)
        x = x - 1
      end
      if @rawBoard[x][y] == color
        dir |= LEFT
      end
    end

    # RIGHT
    x = x1
    y = y1
    if @rawBoard[x+1][y] == -color
      x = x + 1
      while (@rawBoard[x][y] == -color)
        x = x + 1
      end
      if @rawBoard[x][y] == color
        dir |= RIGHT
      end
    end

    # UPPER_LEFT
    x = x1
    y = y1
    if @rawBoard[x-1][y-1] == -color
      x = x - 1
      y = y - 1
      while (@rawBoard[x][y] == -color)
        x = x - 1
        y = y - 1
      end
      if @rawBoard[x][y] == color
        dir |= UPPER_LEFT
      end
    end

    # UPPER_RIGHT
    x = x1
    y = y1
    if @rawBoard[x+1][y-1] == -color
      x = x + 1
      y = y - 1
      while (@rawBoard[x][y] == -color)
        x = x + 1
        y = y - 1
      end
      if @rawBoard[x][y] == color
        dir |= UPPER_RIGHT
      end
    end

    # LOWER_LEFT
    x = x1
    y = y1
    if @rawBoard[x-1][y+1] == -color
      x = x - 1
      y = y + 1
      while (@rawBoard[x][y] == -color)
        x = x - 1
        y = y + 1
      end
      if @rawBoard[x][y] == color
        dir |= LOWER_LEFT
      end
    end

    # LOWER_RIGHT
    x = x1
    y = y1
    if @rawBoard[x+1][y+1] == -color
      x = x + 1
      y = y + 1
      while (@rawBoard[x][y] == -color)
        x = x + 1
        y = y + 1
      end
      if @rawBoard[x][y] == color
        dir |= LOWER_RIGHT
      end
    end

    return dir
  end

  # ひっくり返すメソッド
  def flipDisks(x1, y1)
    dir = @movableDir[x1][y1]
    @rawBoard[x1][y1] = @current_color

    # 上
    x = x1
    y = y1
    if (dir & UPPER) != NONE
      # 置かれた場所の上の石がcurrent_color(置かれた石の色)と違う間の繰り返し
      while @rawBoard[x][y-1] != @current_color
        y = y - 1
        @rawBoard[x][y] = @current_color
      end
    end

    # 下
    x = x1
    y = y1
    # 石が下にあり, ひっくり返せるなら
    if (dir & LOWER) != NONE
      # 置いた石と同じ色の石が見つかるまで繰り返す
      while @rawBoard[x][y+1] != @current_color
        puts "yes\n"
        y = y + 1
        print("down: #{x}, #{y}\n")
        @rawBoard[x][y] = @current_color
      end
      print("end-while #{x}, #{y}\n")
    end

    # 左
    x = x1
    y = y1
    if (dir & LEFT) != NONE
      while @rawBoard[x-1][y] != @current_color
        x = x - 1
        @rawBoard[x][y] = @current_color
      end
    end

    # 右
    x = x1
    y = y1
    if (dir & RIGHT) != NONE
      while @rawBoard[x+1][y] != @current_color
        x = x + 1
        @rawBoard[x][y] = @current_color
      end
    end

    # 左上: x-1, y-1
    x = x1
    y = y1
    if (dir & UPPER_LEFT) != NONE
      while @rawBoard[x-1][y-1] != @current_color
        x = x - 1
        y = y - 1
        @rawBoard[x][y] = @current_color
      end
    end

    # 右上: x+1, y-1
    x = x1
    y = y1
    if (dir & UPPER_RIGHT) != NONE
      while @rawBoard[x+1][y-1] != @current_color
        x = x + 1
        y = y - 1
        @rawBoard[x][y] = @current_color
      end
    end

    # 左下: x-1, y+1
    x = x1
    y = y1
    if (dir & LOWER_LEFT) != NONE
      while @rawBoard[x-1][y+1] != @current_color
        x = x - 1
        y = y + 1
        @rawBoard[x][y] = @current_color
      end
    end

    # 右下: x+1, y+1
    x = x1
    y = y1
    if (dir & LOWER_RIGHT) != NONE
      while @rawBoard[x+1][y+1] != @current_color
        x = x + 1
        y = y + 1
        @rawBoard[x][y] = @current_color
      end
    end
  end

  # isGameOver
  def isGameOver
    # 60手に達していたら終了
    if @turns == MAXTURNS
      return true
    end

    count_none = 0
    # 相手に打てる手があればfalse
    for x in 1..BOARDSIZE do
      for y in 1..BOARDSIZE do

        # 現在の手番で打てる場所があればfalse
        if @movableDir[x][y] == NONE
          return false
        end

        if checkMobility(x, y, -@current_color)
          return false
        end
      end
    end
  end

  def isPass
    # 相手に打てる手があればfalse
    for x in 1..BOARDSIZE do
      for y in 1..BOARDSIZE do

        # 現在の手番で打てる場所があればfalse
        if @movableDir[x][y] != NONE
          return false
        end
      end
    end


    for x in 1..BOARDSIZE do
      for y in 1..BOARDSIZE do
        # 動かせる方向が一つでもあれば
        if checkMobility(x, y, -@current_color) != NONE
          return true
        end
      end
    end


    return false
  end

  # upside-down the stone
  def move(x, y)
    @rawBoard.each do |r|
      print("#{r}\n")
    end
    # ひっくり返せる石がない場合
    if @movableDir[x][y] == NONE
      return false
    end
    # 石をひっくり返すメソッドを呼び出す
    self.flipDisks(x, y)

    # 石を置く
    @rawBoard[x][y] = @current_color


    # 順番交代
    # ターンカウント
    @turns += 1

    # 色反転
    @current_color = -1 * @current_color
    self.initMovable


    return true
  end


=begin
  # GUI
  def loop()

    while true do
      print(" abcdefgh\n")

      for y in 1..BOARDSIZE do
        for x in 1..BOARDSIZE do
          if x == 1
            s = "1".ord + y - 1
            print(s.chr("utf-8"))
          end
          if @rawBoard[x][y] == EMPTY
            print(" ")
          elsif @rawBoard[x][y] == BLACK
            print("○")
          elsif @rawBoard[x][y] == WHITE
            print("●")
          end
        end
        print("\n")
      end
      print("\n")

      if self.isGameOver
        print("ゲーム終了, お疲れ~")
        exit
      end

      if self.isPass
        @movableDir.each do |i|
          print("#{i}\n")
        end
        if @current_color == BLACK
          print("Black")
        elsif
          print("White")
        end
        print("is going to pass.\n")
        # 手番を反転
        @current_color = -@current_color
        # @MovableDirを更新
        self.initMovable
      else
        print("OK\n")

      end


      print("next is")
      if @current_color == BLACK
        print("BLACK")
      elsif
        print("WHITE")
      end
      print(".")

      # validate the input position
      isvalid = false

      while !isvalid do
        print("石を置く座標を入力してください(例: a1 ) ->")
        input = gets.chomp

        if input.length == 2
          x = input[0].ord - "a".ord + 1

          y = input[1].ord - "1".ord + 1

          # もし入力された座標が石を打てる場所であれば, isvalid を true にする
          #p @movableDir
          @rawBoard.each do |e|
            print("#{e}\n")
          end
          print("\n")
          if x.between?(1,BOARDSIZE) and y.between?(1, BOARDSIZE) and @movableDir[x][y] != NONE
            isvalid = true
          end
        end

        if !isvalid
          print("そこには打てまへんで.知らんけど. \n")
        end
      end

      # 石を打ち,(ひっくり返して)手番を入れ替える.ただし今回は石を置くだけで,
      # ひっくり返すのは次回
      move(x, y)
      # p @movableDir
    end
  end
=end
  # GUI 第三回
  def makeWindow
    # 盤の幅と高さ
    w = SWIDTH * 8 + MARGIN * 2
    h = SWIDTH * 8 + MARGIN * 2

    # ルートウィンドウ
    top = TkRoot.new(title: "Othello", width: w, height: h + MHEIGHT)

    # 盤を描くためのキャンパス
    canvas = TkCanvas.new(top, width: w, height: h, borderwidth: 0,
    highlightthickness: 0, background: "darkgreen").place("x" => 0, "y" => 0)

    # 盤の周囲の文字
    for i in 0..BOARDSIZE-1 do
      TkcText.new(canvas, i*SWIDTH + SWIDTH/2 + MARGIN - 4, MARGIN - 10,
      text: ("a".ord + i).chr, fill: "white")
      TkcText.new(canvas, 10, i*SWIDTH + SWIDTH/2 + MARGIN, text: (i+1).to_s, fill: "white")
    end

    # 8x8のマスを描く
    self.drawBoard(canvas)

    # 動作確認用メッセージの表示領域. TkTextでテキストを表示
    frame = TkFrame.new(top, width: w, background: "red",
    height: MHEIGHT).place("x" => 0, "y" => h)

    yscr = TkScrollbar.new(frame).pack("fill"=>"y", "side"=>"right", "expand"=>true)
    text = TkText.new(frame, height: 6).pack("fill" => "both",
    "side"=>"right", "expand" => true)
    text.yscrollbar(yscr)

    # 盤がクリックされた場合の動作を定義, clickされるとclickBoardが呼び出される
    canvas.bind("ButtonPress-1", proc{|x, y|
      self.clickBoard(canvas, text, x, y)
    }, "%x %y")

    return canvas
  end

  # 盤の区画を定義
  def drawBoard(canvas)
    for x in 0..7 do
       for y in 0..7 do
        # マスを一つ描く
        rect = TkcRectangle.new(canvas, MARGIN + x*SWIDTH ,MARGIN  + y*SWIDTH, MARGIN + (x+1)*SWIDTH, MARGIN + (y+1)*SWIDTH)
        # rect = TkcRectangle.new(canvas, MARGIN, MARGIN, MARGIN + SWIDTH, MARGIN　
        rect.configure(fill: "#00aa00")
      end
    end
  end
  # draw disks
   def drawAllDisks(canvas)
     for x in 1..BOARDSIZE do
       for y in 1..BOARDSIZE do
         x1 = MARGIN + (x-1)*SWIDTH
         y1 = MARGIN + (y-1)*SWIDTH
         x2 = MARGIN + x*SWIDTH
         y2 = MARGIN + y*SWIDTH
         if @rawBoard[x][y] != NONE
           disk = TkcOval.new(canvas, x1, y1, x2, y2)
           # if it is black
           if @rawBoard[x][y] == 1
             c = "black"
           elsif @rawBoard[x][y] == -1
             c = "white"
           else
           end
           disk.configure(fill: c)
         end
       end
     end
   end

   def clickBoard(canvas, text, x, y)
     # x1=?
     # y1=?
     for i in 0..7 do
       if x >= MARGIN+i*SWIDTH && x <= MARGIN+(i+1)*SWIDTH
         x1 = i+1
       end
     end
     for j in 0..7 do
       if y >= MARGIN+j*SWIDTH && y <= MARGIN+(i+1)*SWIDTH
         y1 = j+1
       end
     end

     # zahyo
     msg = "(x, y)=(" + x.to_s + "," + y.to_s + ")
     (x1, y1) = (" + x1.to_s + "," + y1.to_s + ")\n"
     text.insert("1.0", msg)

     if !((1..BOARDSIZE).include? x1) or !((1..BOARDSIZE).include? y1)
       return
     end

     if !self.move(x1, y1)
       return
     end
     self.drawAllDisks(canvas)
     Tk.update

     if self.isGameOver
       # 勝敗を調べる
       b = 0
       w = 0
       for x in 1..BOARDSIZE do
         for y in 1..BOARDSIZE do
           if @rawBoard[x][y] != NONE
             if @rawBoard[x][y] == 1
               b += 1
             elsif @rawBoard[x][y] == -1
               w += 1
             end
           end
         end
       end
       if b > w
         winner = "black"
         diff = b - w
       elsif w > b
         winner = "white"
         diff = w - b
       else
         winner = "draw"
       end
       text.insert("1.0", "Game Over. winner is #{winner}. diff is #{diff}\n")
     end

     if self.isPass
       @current_color = -@current_color
       self.initMovable
       text.insert("1.0", "Pass\n")
       return
     end
     # ゲーム終了か、人間が打てるようになるまでコンピュータの手を生成
     loop do
       maxScore = -MAXSCORE
       xmax = 0
       ymax = 0
       # すべての打てる手を生成しそれぞれの手をminmaxで探索
       for x in 1..BOARDSIZE do
         for y in 1..BOARDSIZE do
           puts x
           puts y
           if @movableDir[x][y] != NONE
             # 状態を保存
             tmpBoard = @rawBoard.map(&:dup)
             tmpDir = @movableDir.map(&:dup)
             tmpTurns = @turns
             tmpColor = @current_color

             self.move(x, y)
             # 残りの手数がLIMIT2以下の場合は終盤とする
             if MAXTURNS - @turns <= LIMIT2
               mode = 1
               limit = LIMIT2
             # そうでなければ終盤でない
             else
               mode = 0
               limit = LIMIT
             end
             score = -minmax(limit - 1, mode)
             text.insert('1.0', "(x, y) = (" + x.to_s + "," + y.to_s + "),
             score = " + score.to_s + "\n")

             # 元に戻す
             @rawBoard = tmpBoard.map(&:dup)
             @movableDir = tmpDir.map(&:dup)
             @turns = tmpTurns
             @current_color = tmpColor

             if maxScore < score
               maxScore = score
               xmax = x
               ymax = y
             end
           end
         end
       end
       # もっともスコアが高いところに石を置く
       self.move(xmax, ymax)
       self.drawAllDisks(canvas)
       text.insert('1.0', "選択されたのは(x, y) = (" + xmax.to_s + "," + ymax.to_s + "),
       score = " + maxScore.to_s + "\n")
       Tk.update

       # ゲーム終了ならループを抜ける
       if self.isGameOver
         # 勝敗を調べる
         b = 0
         w = 0
         for x in 1..BOARDSIZE do
           for y in 1..BOARDSIZE do
             if @rawBoard[x][y] != NONE
               if @rawBoard[x][y] == 1
                 b += 1
               elsif @rawBoard[x][y] == -1
                 w += 1
               end
             end
           end
         end
         if b > w
           winner = "black"
           diff = b - w
         elsif w > b
           winner = "white"
           diff = w - b
         else
           winner = "draw"
         end
         text.insert("1.0", "Game Over. winner is #{winner}. diff is #{diff}\n")
         # text.insert('1.0', " ゲーム終了\n")
         break
       # 人間がパスの場合手番を入れ替える
       elsif self.isPass
         @current_color = -@current_color
         self.initMovable
         text.insert('1.0', "パス\n")
       else
         break
       end
     end
   end



   # 探索アルゴリズム(暫定版)
   def minmax(limit, mode)
     score = 0
     maxScore = -MAXSCORE
     # 探索の深さ限度に達したかゲーム終了の場合は評価値を返す
     if limit == 0 or self.isGameOver
       return self.evaluate(mode)
     end

     # パスの場合は手番を変えて探索を続ける
     if self.isPass
       # 状態を保存
       tmpBoard = @rawBoard.map(&:dup)
       tmpDir = @movableDir.map(&:dup)
       tmpTurns = @turns
       tmpColor = @current_color

       # 色を反転して探索
       @current_color = -@current_color
       self.initMovable
       score = -minmax(limit-1, mode)

       # 元に戻す
       @rawBoard = tmpBoard.map(&:dup)
       @movableDir = tmpDir.map(&:dup)

       @turns = tmpTurns
       @current_color = tmpColor

       return score
     end
     # パスでない場合はすべての打てる手を生成しスコアの最も高いものを探す
     for x in 1..BOARDSIZE do
       for y in 1..BOARDSIZE do
         if @movableDir[x][y] != NONE
           # 現在の盤の状態を保存
           tmpBoard = @rawBoard.map(&:dup)
           tmpDir = @movableDir.map(&:dup)
           tmpTurns = @turns
           tmpColor = @current_color
           # 石を打つ
           self.move(x, y)
           # minmaxを呼び出す
           score = -minmax(limit - 1, mode)

           # 盤の状態を元に戻す
           @rawBoard = tmpBoard.map(&:dup)
           @movableDir = tmpDir.map(&:dup)
           @turns = tmpTurns
           @current_color = tmpColor

           if maxScore < score
             maxScore = score
           end

         end
       end
     end
     return maxScore
   end




   def numDisks
     score = 0
     for x in 1..BOARDSIZE do
       for y in 1..BOARDSIZE do
         if @rawBoard[x][y] == @current_color
           score += 1
         end
         if @rawBoard[x][y] == -@current_color
           score -= 1
         end
       end
     end
     return score
   end

   def evaluate(mode)
     score = self.numDisks
     return score
   end
end



# Boardインスタンスの作成
board = Board.new

# 盤を初期化
board.init
canvas = board.makeWindow
board.drawAllDisks(canvas)
Tk.mainloop
