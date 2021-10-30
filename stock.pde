import java.util.ArrayList;
import java.text.*;

int width = 1920, height = 1080, framerate = 144, filling = 0, colorIndex, offsetIndex = 0, strokeW = 5;
float count = 0, countMax = 100, interval = 0;
float ypos, variance, startingPrice, price = 15, stretch = 25;
float targetY, easing = 0.1, yoffset = 0, xoffset = 0, cameraOffset = -(height/2), scaleY = 1;
float multiplier, priceChangeDivider, calculatedPrice, bottomLine;
boolean hideEarlier = true, hideBottom = false;
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

    bottomLine = nodes.get(0);

    colors[0] = color(98,235,52); // GREEN
    colors[1] = color(3,161,252); // BLUE
    colors[2] = color(235,52,82); // RED
    colors[3] = color(255,255,255); // WHITE

    // Price movement multipliers
    /*
    $150 = {1, 1000}
    $15 = {1, 100}
    */
    multiplier = 1;
    priceChangeDivider = 1000;
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
    }else if(keyCode == 10){ // ENTER
        hideEarlier = !hideEarlier;
    }else if(keyCode == 40){ // DOWN
        scaleY -= 0.1;
    }else if(keyCode == 38){ // UP
        scaleY += 0.1;
    }else if(keyCode == 17){
        startingPrice = (nodes.get(0) - ypos)/priceChangeDivider + price;
        bottomLine = ypos;
    }else if(keyCode == 16){
        hideBottom = !hideBottom;
    }
    //print(keyCode);
}

void repeatLine(color s, color e, float x, float y, float xx, float yy){
    float scale = 75;
    float m = strokeW;
    strokeWeight(strokeW*2.5);
    for (int i = 1; i < int(scale); i++) {
        stroke(lerpColor(s, e, i/scale));
        line(x,y+i*m,xx,yy+i*m);
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
    s.vertex(xx, bottomLine-(yoffset + cameraOffset));
    s.vertex(x, bottomLine-(yoffset + cameraOffset));
    s.endShape(CLOSE);
    shape(s);
}

void drawFillOptimized(color c){
    PShape s;
    s = createShape();
    s.beginShape();
    s.fill(c);
    s.noStroke();
    for(int i = 0; i < nodes.size(); i++){
        int p = i+1;
        if(i > offsetIndex && hideEarlier){
            s.vertex(width/2-(i*stretch)-xoffset, height);
            s.vertex(width/2, height);
            s.vertex(width/2, ypos-(yoffset + cameraOffset));
            break;
        }
        if(i == 0){
            s.vertex(width/2-(p*stretch)-xoffset, (nodes.get(i)*scaleY)-(yoffset + cameraOffset));
            s.vertex(width/2, ypos-(yoffset + cameraOffset));
        }else{
            s.vertex(width/2-((p-1)*stretch)-xoffset, (nodes.get(i-1)*scaleY)-(yoffset + cameraOffset));
            s.vertex(width/2-(p*stretch)-xoffset, (nodes.get(i)*scaleY)-(yoffset + cameraOffset));
        }
        if(i == nodes.size()-1){
            s.vertex(width/2-(i*stretch)-xoffset, height);
            s.vertex(width/2, height);
            s.vertex(width/2, ypos-(yoffset + cameraOffset));
        }
    }
    s.endShape(CLOSE);
    shape(s);
}

color divideColor(color c, float d){
    return color(red(c)*d,green(c)*d,blue(c)*d);
}

void dottedLine(color c, float scale, float x, float y, float xx, float yy){
    stroke(c);
    strokeWeight(strokeW);
    for(int i = 0; i < int(scale); i++) {
        // MAKE LINE DARKER AFTER IT REACHES THE CENTER
        if(((scale-i)*x + i*xx)/scale > width/2){
            stroke(divideColor(c,0.5));
            //stroke(c);
        }else{
            stroke(c);
        }
        if(i % 2 == 0){
            line(((scale-i)*x + i*xx)/scale,
            ((scale-i)*y + i*yy)/scale,
            ((scale-i-1)*x + (i+1)*xx)/scale,
            ((scale-i-1)*y + (i+1)*yy)/scale);
        }
    }
}

void draw() {
    surface.setTitle(round(frameRate) + " fps");
    background(0);

    //DRAW UNDER LINES
    if(filling == 1 || filling == 3){
        for(int i = 0; i < nodes.size(); i++){
            int p = i+1;
            float m = 0.5;
            if(width/2-((p-1)*stretch)-xoffset < 0 || (i > offsetIndex && hideEarlier)){
                break;
            }
            if(i == 0){
                if(filling == 1){
                    repeatLine(divideColor(colors[colorIndex],m), color(0,0,0), width/2-(p*stretch)-xoffset, nodes.get(i)-(yoffset + cameraOffset), width/2-2, ypos-(yoffset + cameraOffset));
                }else{
                    drawFill(divideColor(colors[colorIndex],m), width/2-(p*stretch)-xoffset-(stretch>0 ? 1 : -1), nodes.get(i)-(yoffset + cameraOffset), width/2+1, ypos-(yoffset + cameraOffset));
                }
            }else{
                if(filling == 1){
                    repeatLine(divideColor(colors[colorIndex],m), color(0,0,0), width/2-(p*stretch)-xoffset, nodes.get(i)-(yoffset + cameraOffset), width/2-((p-1)*stretch)-xoffset, nodes.get(i-1)-(yoffset + cameraOffset));
                }else{
                    drawFill(divideColor(colors[colorIndex],m), width/2-(p*stretch)-xoffset-(stretch>0 ? 1 : -1), nodes.get(i)-(yoffset + cameraOffset), width/2-((p-1)*stretch)-xoffset, nodes.get(i-1)-(yoffset + cameraOffset));
                }
            }
        }
    }else if(filling == 2){
        drawFillOptimized(divideColor(colors[colorIndex],0.5));
    }

    //BOTTOM LINE
    if(hideBottom){
        dottedLine(color(255*0.33), 175, 0, bottomLine-(yoffset + cameraOffset), width, bottomLine-(yoffset + cameraOffset));
    }

    if(hideEarlier && nodes.get(offsetIndex)-(yoffset + cameraOffset) != bottomLine-(yoffset + cameraOffset)){
        dottedLine(colors[colorIndex], 50, width/2-((offsetIndex+1)*stretch)-xoffset,nodes.get(offsetIndex)-(yoffset + cameraOffset), width/2-((offsetIndex+1)*stretch)-xoffset-1000, nodes.get(offsetIndex)-(yoffset + cameraOffset));
    }

    //DRAW NODES
    for(int i = 0; i < nodes.size(); i++){
        stroke(colors[colorIndex]);
        strokeWeight(strokeW);
        int p = i+1;
        if(i > offsetIndex && hideEarlier){
            break;
        }
        if(i == 0){
            line(width/2-(p*stretch)-xoffset, (nodes.get(i)*scaleY)-(yoffset + cameraOffset), width/2, ypos-(yoffset + cameraOffset));
        }else{
            line(width/2-(p*stretch)-xoffset, (nodes.get(i)*scaleY)-(yoffset + cameraOffset), width/2-((p-1)*stretch)-xoffset, (nodes.get(i-1)*scaleY)-(yoffset + cameraOffset));
        }
    }

    //CALCULATE PRICE AND DRAW TEXT
    fill(255);
    textAlign(LEFT);
    textSize(100);
    calculatedPrice = (nodes.get(0) - ypos)/priceChangeDivider + price;
    text("$" + convertFloatToPrice(calculatedPrice), width/2 + 50, ypos-(yoffset + cameraOffset) + 30);

    //DRAW STOCK + PRICE % CHANGE
    textSize(50);
    fill(255*0.5);
    String stock = "AAPL ";
    text(stock, width/2 + 50, ypos-(yoffset + cameraOffset) + 90);
    fill(calculatedPrice > startingPrice ? divideColor(colors[0],0.8) : divideColor(colors[2],0.8));
    text((calculatedPrice > startingPrice ? "+" : "")+convertFloatToPrice((calculatedPrice / startingPrice * 100)-100)+"%", width/2 + 50 + textWidth(stock), ypos-(yoffset + cameraOffset) + 90);

    //EASING
    float dy = ypos - yoffset;
    float dx = targetY - ypos;
    float dxo = 0 - xoffset;

    //CALCULATE NEW PRICE IF TARGET IS REACHED
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
