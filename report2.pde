import ddf.minim.*;

Minim minim;
AudioPlayer effect;
AudioPlayer play_bgm;
AudioPlayer over_bgm;

PImage f1_img;
PImage f2_img;
PImage f3_img;
PImage f4_img;

int stage = 0;
int px = 200;      //自機のx座標
int py = 420;      //自機のy座標
int pw = 40;      //自機の幅
int ph = 5;      //自機の高さ
float bx;      //ボール　座標
float by;
float spdx;      //ボール　速度
float spdy;
int bw = 7;      //ボール　幅と高さ
int bh = 7;
int phit = 0;
int blw = 118;
int blh = 30;
int[] blf = new int[25];
float lastx;
float lasty;
int bexist = 0;
int score;
int mcnt;      //メッセージ用カウンタ

//起動後に1度だけ処理される関数
void setup(){
  size(600, 480);
  noStroke();
  f1_img = loadImage("data/field1.png");
  f2_img = loadImage("data/field2.png");
  f3_img = loadImage("data/field3.png");  
  f4_img = loadImage("data/gameover.png");
  minim = new Minim(this);
  effect = minim.loadFile("jump07.mp3");
  play_bgm = minim.loadFile("bgm_play.mp3");
  over_bgm = minim.loadFile("bgm_gameover.mp3");
  colorMode(HSB,100,100,100);      //カラーモードの設定
  gameInit();    //ゲーム関連の初期化
}

//毎フレームごとに呼び出される関数
void draw(){
  background(0);
  if( stage == 0){
    gameTitle();      //ゲームタイトル画面
  }else if( stage == 1 ){
    image(f1_img, 0, 0);
    gamePlay();      //プレイ中の画面
  }else if( stage == 2 ){
    image(f2_img, 0, 0);
    gamePlay();      //プレイ中の画面
  }else if( stage == 3 ){
    image(f3_img, 0, 0);
    gamePlay();      //プレイ中の画面
  }else{
    image(f4_img, 0, 0);
    gameOver();      //ゲームオーバー画面
  }
}

//ユーザー定義関数
void gameInit(){
  stage = 0;
  bx = 100;
  by = 250;
  spdx = 2;
  spdy = 2;
  phit = 0;
  for(int i=0; i<25; i++){
    blf[i] = 1;
  }
  bexist = 0;
  score = 0;
  mcnt = 0;
  play_bgm.rewind();
  play_bgm.play();
  play_bgm.rewind();
}

void gameTitle(){
  playerMove();
  playerDisp();
  blockDisp();
  scoreDisp();
  mcnt++;
  if((mcnt%60) < 40){
    textSize(20);
    fill(20, 100, 100);
    text("Click to start!", 230, 360);
  }
}

void gamePlay(){
  playerMove();
  playerDisp();
  blockDisp();
  ballMove();
  ballDisp();
  scoreDisp();
  
}

void gameOver(){
  playerDisp();
  blockDisp();
  scoreDisp();
  textSize(50);
  fill(1, 100, 100);
  text("GAME OVER", 150, 300);
  mcnt++;
  if((mcnt%60) < 40){
    textSize(20);
    fill(20, 100, 100);
    text("Click to retry!", 230, 360);
  }
}

void playerDisp(){
  fill(0,0,100);
  rect(px, py, pw, ph, 5);      //角を丸くする
}

void playerMove(){
  px = mouseX;      //マウスカーソルのX座標を取得
  if((px + pw) > width){      //自機がはみ出しても隠れないようにする
    px = width - pw;
  }
}

void ballDisp(){
  imageMode(CENTER);    //絵の中心が基点
  fill(0,100,100);
  rect(bx,by,bw,bh);
  imageMode(CORNER);    //絵の左上が基点
}

void ballMove(){
  lastx = bx;
  lasty = by;
  bx += spdx;
  by += spdy;
  if(by > height){      //画面下へ出た時
//    spdy = -spdy;
    play_bgm.pause();
    over_bgm.rewind();
    over_bgm.play();
    stage = 4;
  }
  if(by < 0){      //画面上へ出た時
    spdy = -spdy;
  }
  if((bx < 0) || (bx > width)){    //画面左右へ出た時
    spdx = -spdx;
  }
  //自機との当たり判定
  if((phit == 0) && (px < bx) && (px + pw > bx)
  && (py < by) && (py + ph > by)){
    spdy = -spdy;
    phit = 1;
    effect.play();
    effect.rewind();
    if(bexist == 0){
      stage += 1;
      for(int i = 0; i < 25; i++){
        blf[i] = 1;
      }
      score += 100;
    }
  }
  if(by < py-30){
    phit = 0;
  }
}

void blockDisp(){
  int xx, yy;
  int zz = 0;
  bexist = 0;
  if(stage == 1){
    zz = 1;
  }else if(stage == 2){
    zz =10;
  }
  bexist = 0;
  for(int i=0; i < zz; i++){
    if(blf[i] == 1){
      fill((i/5)*15, 100, 100);
      xx = (i%5) * (blw+2);
      yy = 50 + (i/5) * (blh+2);
      blockHitCheck(i, xx, yy);
      if(blf[i] == 1){
        rect(xx, yy, blw, blh, 2);
        bexist = 1;
      }
    }
  }
}

void blockHitCheck(int ii, int xx, int yy){
  if(!((xx < bx) && (xx+blw > bx) && (yy < by) && (yy+blh > by))){
    return;
  }
  blf[ii] = 0;
  score += 10;
  if(ii < 10){
    score += 10;
  }  
  if((xx < lastx) && (xx + blw > lastx)){
    spdy = -spdy;
    return;
  }
  if((yy < lasty) && (yy+blh > lasty)){
    spdx = -spdx;
    return;
  }
  spdx = -spdx;
  spdy = -spdy;
}

void scoreDisp(){
  textSize(24);      //文字のサイズ
  fill(0,0,100);      //文字の色
  text("score:" + score, 10, 25);
}

void mousePressed(){      //クリックしたときに呼ばれる
  if(stage == 0){
    stage = 1;
  }
  if(stage == 4){
    over_bgm.pause();
    gameInit();
  }
}
