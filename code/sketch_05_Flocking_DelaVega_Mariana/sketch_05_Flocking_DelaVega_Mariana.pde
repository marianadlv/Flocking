/* REFERENCES: 
Used g4p library for the sliders and minim library for the audio.
*/

import g4p_controls.*;
import ddf.minim.*;
import static javax.swing.JOptionPane.*;

// list of boids

ArrayList<Boid> all = new ArrayList<Boid>();
ArrayList<Enemy> enemies = new ArrayList<Enemy>();

// for the audio

boolean night, leader;
AudioSnippet dayAudio, nightAudio;
Minim minim, minim2;

// for the sliders

GCustomSlider alignWeight, cohesionWeight, separationWeight, maxF, maxS, perceptionRadius, separationDistance; 

// for the button 

GImageButton btn, btn2, btn3;
String[] files = {"night.png"};
String[] files2 = {"leader.png"};
String[] files3 = {"question.png"};

void setup() {

  size(900, 800);
  
  // show instructions
  showMessageDialog(null, "Instructions:\n1. To add new boids click on the screen.\n2. To delete boids press the delete key.\n3. Play with the values by using the sliders.\n4. Click the moon/sun image to change mode.\n5. Set the mouse in the desired position and press e/E to add an obstacle.\n6. Press tab to delete an obstacle.\n7. Click the leader image to follow/unfollow a leader.\n8. Click the question mark to read the instructions again.");
  
  // audio

  minim = new Minim(this);
  minim2 = new Minim(this);
  dayAudio = minim.loadSnippet("play.mp3");
  nightAudio = minim.loadSnippet("play2.mp3");
  night = false;
  
  // button
  
  btn = new GImageButton(this, 20, 90,60,60, files);
  btn2 = new GImageButton(this, 20, 160,60,60, files2);
  btn3 = new GImageButton(this, 27, 230,40,40, files3);
  
  // sliders
  
  alignWeight = new GCustomSlider(this,5,height-30,290,20);
  alignWeight.setShowDecor(false,false,false,false);
  alignWeight.setLimits(0.0,3.0);

  cohesionWeight = new GCustomSlider(this,305,height-30,290,20);
  cohesionWeight.setShowDecor(false,false,false,false);
  cohesionWeight.setLimits(0.0,3.0);
  
  separationWeight = new GCustomSlider(this,605,height-30,290,20);
  separationWeight.setShowDecor(false,false,false,false);
  separationWeight.setLimits(0.0,3.0);
  
  alignWeight.setValue(1.31);
  cohesionWeight.setValue(1.31);
  separationWeight.setValue(1.31);
  
  maxF = new GCustomSlider(this,790,45,100,20);
  maxF.setShowDecor(false,false,false,false);
  maxF.setLimits(0,0.0,0.2);
  maxF.setValue(0.02);
  
  maxS = new GCustomSlider(this,790,105,100,20);
  maxS.setShowDecor(false,false,false,false);
  maxS.setLimits(0,0,10);
  maxS.setValue(4);
  
  perceptionRadius = new GCustomSlider(this,5,45,150,20);
  perceptionRadius.setShowDecor(false,false,false,false);
  perceptionRadius.setLimits(0,0,400);
  perceptionRadius.setValue(150);
  
  separationDistance = new GCustomSlider(this,790,165,100,20);
  separationDistance.setShowDecor(false,false,false,false);
  separationDistance.setLimits(0,0,100);
  separationDistance.setValue(20);
  
  // initialize list of boids

  int n = 70;

  for (int i = 0; i < n; i++) {
    all.add(new Boid());
  }
  
}

void draw() {
  
  clear();
  
  // color of background
  
  if (night) background(0,0,0);
  else background(255,255,255);
  
  // which audio to play
  
  if(!night) {
    nightAudio.pause();
    if (dayAudio.isPlaying()) dayAudio.play();
    else {
      dayAudio.pause();
      dayAudio.rewind();
      dayAudio.play();
    }
  } else {
    dayAudio.pause();
    if (nightAudio.isPlaying()) nightAudio.play();
    else {
      nightAudio.pause();
      nightAudio.rewind();
      nightAudio.play();
    } 
  }
  
  // color of text
  
  if (night) fill(255,255,255);
  else fill(0,0,0);
  
  text("Alignment : "+nf(alignWeight.getValueF(),0,2),100,height-35);
  text("Cohesion: "+nf(cohesionWeight.getValueF(),0,2),400,height-35);
  text("Separation: "+nf(separationWeight.getValueF(),0,2),700,height-35);
  text("Max Force: "+nf(maxF.getValueF(),0,2),795,30);
  text("Max Speed: "+nf(maxS.getValueF(),0,1),795,90);
  
  text("Perception Radius: "+perceptionRadius.getValueI(),10,30);
  text("Separation\ndistance: "+separationDistance.getValueI(),800,145);
  
  // update position of each boid
  
  for (Enemy e: enemies) e.drawEnemy();
  
  for (Boid item: all) item.update(all,enemies,night,leader);
  
  // draw each boid
  
  for (Boid item: all) item.drawBoid();

}

  // button

void handleButtonEvents(GImageButton button, GEvent event) {
  if (button == btn) night = !night;
  else if (button == btn2) {
    leader = !leader;
    if (leader) {
      if (all.size()>0) {
        all.get(0).setLeader(true);
        all.get(0).setLength(15);
      }
    } else {
      if (all.size()>0) {
        all.get(0).setLeader(false);
        all.get(0).setLength(5);
      }
    }
  } else if (button == btn3) {
     showMessageDialog(null, "Instructions:\n1. To add new boids click on the screen.\n2. To delete boids press the delete key.\n3. Play with the values by using the sliders.\n4. Click the moon/sun image to change mode.\n5. Set the mouse in the desired position and press e/E to add an obstacle.\n6. Press tab to delete an obstacle.\n7. Click the leader image to follow/unfollow a leader.");
  }
}

  // add boids

void mousePressed() {
  all.add(new Boid(mouseX,mouseY));
}

  // delete boids
  
void keyPressed() {
  
  if (key == BACKSPACE) if (all.size()>0) all.remove(all.size()-1);
  if (key == 'e' || key == 'E') enemies.add(new Enemy(mouseX,mouseY));
  if (key == TAB) if(enemies.size()>0) enemies.remove(enemies.size()-1);
}