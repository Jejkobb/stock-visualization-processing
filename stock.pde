import java.util.ArrayList;
import java.text.*;

int width = 1920, height = 1080, framerate = 60;
float count = 0, countMax = 100, interval = 0;
float ypos, variance, startingPrice, price = 10, stretch = 25;
float targetY, easing = 0.1, yoffset = 0, xoffset = 0, cameraOffset = -500;
boolean gradient;

ArrayList<Float> nodes = new ArrayList();

void settings(){
    size(width,height);
}

void setup() {
    frameRate(framerate);
    ypos = height/2;
    targetY = random(height/2-variance, height/2+variance);
    variance = 50;
    startingPrice = price;

    for(int i = 0; i < 100; i++){
        if(i == 0){
            nodes.add(i, random(height/2-variance, height/2+variance));
        }else{
            nodes.add(i, random(nodes.get(i-1)-variance, nodes.get(i-1)+variance));
        }
    }
}

String convertFloatToPrice(float n){
    DecimalFormat df = new DecimalFormat("0.00");
    String s = df.format(n);
    char[] chars = s.toCharArray();
    for(int i = 0; i < chars.length; i++){
        if(chars[i] == ','){
            chars[i] = '.';
        }
    }
    return String.valueOf(chars);
}

void mouseWheel(MouseEvent event) {
    stretch += event.getCount();
}

void keyPressed() {
    print(keyCode);
    if(keyCode == 32){
        gradient = !gradient;
    }
}

void gradiant_line(color s, color e, float x, float y, float xx, float yy) {
  for (int i = 0; i < 100; i++) {
    stroke(lerpColor(s, e, i/100.0));
    line(((100-i)*x + i*xx)/100.0, ((100-i)*y + i*yy)/100.0, 
      ((100-i-1)*x + (i+1)*xx)/100.0, ((100-i-1)*y + (i+1)*yy)/100.0 );
  }
}

void repeatLine(color s, color e, float x, float y, float xx, float yy){
    float scale = 75;
    float multiplier = 5;
    strokeWeight(10);
    for (int i = 1; i < int(scale); i++) {
        stroke(lerpColor(s, e, i/scale));
        line(x,y+i*multiplier,xx,yy+i*multiplier);
    }
}

void draw() {
    background(0);

    //DRAW GRADIENT
    if(gradient){
        for(int i = 0; i < nodes.size(); i++){
        int p = i+1;
        if(width/2-((p-1)*stretch)-xoffset < 0){
            break;
        }
        if(i == 0){
            repeatLine(color(0,100,0), color(0,0,0), width/2-(p*stretch)-xoffset, nodes.get(i)-(yoffset + cameraOffset), width/2-2, ypos-(yoffset + cameraOffset));
        }else{
            repeatLine(color(0,100,0), color(0,0,0), width/2-(p*stretch)-xoffset, nodes.get(i)-(yoffset + cameraOffset), width/2-((p-1)*stretch)-xoffset, nodes.get(i-1)-(yoffset + cameraOffset));
        }
    }
    }

    //DRAW NODES
    for(int i = 0; i < nodes.size(); i++){
        stroke(0,255,0);
        strokeWeight(5);
        int p = i+1;
        if(i == 0){
            line(width/2-(p*stretch)-xoffset, nodes.get(i)-(yoffset + cameraOffset), width/2, ypos-(yoffset + cameraOffset));
        }else{
            line(width/2-(p*stretch)-xoffset, nodes.get(i)-(yoffset + cameraOffset), width/2-((p-1)*stretch)-xoffset, nodes.get(i-1)-(yoffset + cameraOffset));
        }
    }

    fill(255);
    textAlign(LEFT);
    textSize(100);
    float calculatedPrice = (nodes.get(0) - ypos)/100 + price;
    text("$" + convertFloatToPrice(calculatedPrice), width/2 + 50, ypos-(yoffset + cameraOffset) + 25);

    float dy = ypos - yoffset;
    float dx = targetY - ypos;
    float dxo = 0 - xoffset;

    float multiplier = 1;
    float bounce = (1 - (calculatedPrice < startingPrice ? calculatedPrice/startingPrice : 1)) * 100;
    if(dx < 0.05 && dx > -0.05){
        targetY = ypos+random(variance*-multiplier-bounce*multiplier, variance*multiplier-bounce*multiplier);
    }

    //ADD HISTORY NODE TO CHART
    interval+=1;
    if(interval > framerate*2){
        nodes.add(0,ypos);
        price = calculatedPrice;
        interval = 0;
        xoffset = -stretch;
    }

    xoffset += dxo * easing;
    ypos += dx * easing;
    yoffset += dy * (easing/2);

    noStroke();

    //Circles
    float w = 25;
    fill(0,255,0,255 - (count / countMax * 255));
    ellipse(width/2, ypos-(yoffset + cameraOffset), w+count, w+count);

    fill(0,255,0);
    ellipse(width/2, ypos-(yoffset + cameraOffset), w, w);

    count = count < countMax ? count+1 : 0;
}
