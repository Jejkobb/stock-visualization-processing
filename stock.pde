import java.util.ArrayList;
import java.text.*;

int width = 1920, height = 1080, framerate = 144, filling = 0, colorIndex, offsetIndex = 0, strokeW = 5;
float count = 0, countMax = 100, interval = 0;
float ypos, variance, startingPrice, price = 0.5, stretch = 25;
float targetY, easing = 0.1, yoffset = 0, xoffset = 0, cameraOffset = -(height/2), scaleY = 1;
boolean hideEarlier = true;
color[] colors = new color[4];

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
    colors[0] = color(98,235,52); // GREEN
    colors[1] = color(3,161,252); // BLUE
    colors[2] = color(235,52,82); // RED
    colors[3] = color(255,255,255); // WHITE
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
    if(keyCode == 32){ // SPACE
        filling = filling < 3 ? filling+1 : 0;
    }else if(keyCode == 39){ // RIGHT ARROW
        colorIndex = colorIndex == colors.length-1 ? 0 : colorIndex+1;
    }else if(keyCode == 37){ // LEFT ARROW
        colorIndex = colorIndex == 0 ? colors.length-1 : colorIndex-1;
    }else if(keyCode == 10){
        hideEarlier = !hideEarlier;
    }
}

void repeatLine(color s, color e, float x, float y, float xx, float yy){
    float scale = 75;
    float multiplier = 5;
    strokeWeight(strokeW*2);
    for (int i = 1; i < int(scale); i++) {
        stroke(lerpColor(s, e, i/scale));
        line(x,y+i*multiplier,xx,yy+i*multiplier);
    }
}

void drawFill(color c, float x, float y, float xx, float yy){
    PShape s;
    s = createShape();
    s.beginShape();
    s.fill(c);
    s.noStroke();
    s.vertex(x, y);
    s.vertex(xx, yy);
    if(filling == 3){
        s.vertex(xx, nodes.get(offsetIndex)-(yoffset + cameraOffset));
        s.vertex(x, nodes.get(offsetIndex)-(yoffset + cameraOffset));
    }else{
        s.vertex(xx, height);
        s.vertex(x, height);
    }
    s.endShape(CLOSE);
    shape(s);
}

void dottedLine(color c, float scale, float x, float y, float xx, float yy){
    stroke(c);
    strokeWeight(strokeW);
    for(int i = 0; i < int(scale); i++) {
        if(i % 2 == 0){
            line(((scale-i)*x + i*xx)/scale, ((scale-i)*y + i*yy)/scale, 
            ((scale-i-1)*x + (i+1)*xx)/scale, ((scale-i-1)*y + (i+1)*yy)/scale );
        }
    }
}

void draw() {
    surface.setTitle(round(frameRate) + " fps");
    background(0);

    //DRAW UNDER LINES
    if(filling > 0){
        for(int i = 0; i < nodes.size(); i++){
            int p = i+1;
            float m = 0.5;
            if(width/2-((p-1)*stretch)-xoffset < 0 || (i > offsetIndex && hideEarlier)){
                break;
            }
            if(i == 0){
                if(filling == 1){
                    repeatLine(color(red(colors[colorIndex])*m,green(colors[colorIndex])*m,blue(colors[colorIndex])*m), color(0,0,0), width/2-(p*stretch)-xoffset, nodes.get(i)-(yoffset + cameraOffset), width/2-2, ypos-(yoffset + cameraOffset));
                }else{
                    drawFill(color(red(colors[colorIndex])*m,green(colors[colorIndex])*m,blue(colors[colorIndex])*m), width/2-(p*stretch)-xoffset-(stretch>0 ? 1 : -1), nodes.get(i)-(yoffset + cameraOffset), width/2+1, ypos-(yoffset + cameraOffset));
                }
            }else{
                if(filling == 1){
                    repeatLine(color(red(colors[colorIndex])*m,green(colors[colorIndex])*m,blue(colors[colorIndex])*m), color(0,0,0), width/2-(p*stretch)-xoffset, nodes.get(i)-(yoffset + cameraOffset), width/2-((p-1)*stretch)-xoffset, nodes.get(i-1)-(yoffset + cameraOffset));
                }else{
                    drawFill(color(red(colors[colorIndex])*m,green(colors[colorIndex])*m,blue(colors[colorIndex])*m), width/2-(p*stretch)-xoffset-(stretch>0 ? 1 : -1), nodes.get(i)-(yoffset + cameraOffset), width/2-((p-1)*stretch)-xoffset, nodes.get(i-1)-(yoffset + cameraOffset));
                }
            }
        }
    }

    //BOTTOM LINE
    dottedLine(color(255*0.33), 100, 0, nodes.get(offsetIndex)-(yoffset + cameraOffset), width, nodes.get(offsetIndex)-(yoffset + cameraOffset));

    //DRAW NODES
    for(int i = 0; i < nodes.size(); i++){
        stroke(colors[colorIndex]);
        strokeWeight(strokeW);
        int p = i+1;
        if(i > offsetIndex && hideEarlier){
            break;
        }
        if(i == 0){
            line(width/2-(p*stretch)-xoffset, nodes.get(i)-(yoffset + cameraOffset) * scaleY, width/2, ypos-(yoffset + cameraOffset));
        }else{
            line(width/2-(p*stretch)-xoffset, nodes.get(i)-(yoffset + cameraOffset) * scaleY, width/2-((p-1)*stretch)-xoffset, nodes.get(i-1)-(yoffset + cameraOffset));
        }
    }

    //CALCULATE PRICE AND DRAW TEXT
    fill(255);
    textAlign(LEFT);
    textSize(100);
    float priceChangeDivider = 1000;
    float calculatedPrice = (nodes.get(0) - ypos)/priceChangeDivider + price;
    text("$" + convertFloatToPrice(calculatedPrice), width/2 + 50, ypos-(yoffset + cameraOffset) + 30);
    textSize(50);
    fill(255*0.5);
    text("AAPL", width/2 + 50, ypos-(yoffset + cameraOffset) + 90);

    //EASING
    float dy = ypos - yoffset;
    float dx = targetY - ypos;
    float dxo = 0 - xoffset;

    //CALCULATE NEW PRICE IF TARGET IS REACHED
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
        offsetIndex++;
    }

    //APPLY EASING
    xoffset += dxo * easing;
    ypos += dx * easing;
    yoffset += dy * (easing/2);

    noStroke();

    //DRAW CIRCLES
    float w = 25;
    fill(colors[colorIndex],255 - (count / countMax * 255));
    ellipse(width/2, ypos-(yoffset + cameraOffset), w+count, w+count);

    fill(colors[colorIndex]);
    ellipse(width/2, ypos-(yoffset + cameraOffset), w, w);

    count = count < countMax ? count+1 : 0;
}
