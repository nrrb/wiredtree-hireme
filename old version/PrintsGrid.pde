import controlP5.*;

ControlP5 cp5;

final int DISPLAY_SIZE = 400;

final int SLIDER_THICKNESS = 20;
final int PADDING = 80;

final int PRINT_WIDTH = 6;
final int PRINT_HEIGHT = 4;
final float PRINT_COST = 0.09;

int displayinch_x, displayinch_y;
int imagepx_x, imagepx_y;
int screenpx_x, screenpx_y;
int printinch_x, printinch_y;
float printpx_x, printpx_y;
int prints_wide, prints_high;
int imageorigin_x, imageorigin_y;

PImage img;
Slider slider_width, slider_height;
String save_path, load_path;

// It's reasonable to say the max size will be 12 feet square
final int MAX_WIDTH_INCHES = 12 * 12; 
final int MAX_HEIGHT_INCHES = 12 * 12;
// We don't actually know the print DPI that snapfish uses,
// but they'll shrink or grow any size image to fit the space
final int DPI = 300;

Textarea totals_area;

void setup() {
  size(600, 600);
  printinch_x = PRINT_WIDTH;
  printinch_y = PRINT_HEIGHT;
  load_path = "qtogb.jpg";
  img = loadImage(load_path);
  calculate_image_scaling();

  cp5 = new ControlP5(this);
  
  totals_area = cp5.addTextarea("totals_display")
    .setText("poopy")
    .setPosition(PADDING*3, height-PADDING)
    .setFont(createFont("Anonymous", 14));

  slider_width = cp5.addSlider("final_width")
     .setPosition(0, 0)
     .setSize(width - 2*PADDING, SLIDER_THICKNESS)
     .setRange(0, MAX_WIDTH_INCHES)
     .setValue(printinch_x)
     .setNumberOfTickMarks(1 + (MAX_WIDTH_INCHES / printinch_x));
     
  // Vertical slider at the right right side of the screen to adjust height
  slider_height = cp5.addSlider("final_height")
     .setPosition(width-(PADDING+SLIDER_THICKNESS), PADDING)
     .setSize(SLIDER_THICKNESS, height - 2*PADDING)
     .setRange(0, MAX_HEIGHT_INCHES)
     .setValue(printinch_y)
     .setNumberOfTickMarks(1 + (MAX_HEIGHT_INCHES / printinch_y));
  
  cp5.addButton("load_image")
    .setPosition(PADDING/2, height-PADDING)
    .setSize(PADDING, PADDING/2);
  cp5.addButton("save_prints")
    .setPosition(PADDING*2, height-PADDING)
    .setSize(PADDING, PADDING/2);    
}

void draw() {
  background(0);
  imageorigin_x = 0;
  imageorigin_y = (height - screenpx_y) / 2;
  if(img != null) {
    image(img, imageorigin_x, imageorigin_y, screenpx_x, screenpx_y);
    drawGrid();
  }
}

void calculate_image_scaling() {
  imagepx_x = img.width;
  imagepx_y = img.height;
  if(imagepx_y > imagepx_x) {
    screenpx_y = DISPLAY_SIZE;
    screenpx_x = (screenpx_y * imagepx_x) / imagepx_y;
  }
  else {
    screenpx_x = DISPLAY_SIZE;
    screenpx_y = (screenpx_x * imagepx_y)/imagepx_x;
  }
}

void final_width(int disp_x) {
  displayinch_x = disp_x;
  displayinch_y = (disp_x * imagepx_y) / imagepx_x;
//  if(slider_height != null) {
//    slider_height.setValue(displayinch_y);
//  }
  recalculate();
}

void final_height(int disp_y) {
  displayinch_y = disp_y;
  displayinch_x = (disp_y * imagepx_x) / imagepx_y;
  recalculate();
}

void recalculate() {
  prints_wide = displayinch_x / printinch_x;
  if(displayinch_x % printinch_x > 0) {
    prints_wide ++;
  }
  prints_high = displayinch_y / printinch_y;
  if(displayinch_y % printinch_y > 0) {
    prints_high ++;
  }
  printpx_x = (float)screenpx_x / (float)prints_wide;
  printpx_y = (float)screenpx_y / (float)prints_high;
  int total_prints = prints_wide * prints_high;
  float cost = (float)total_prints * PRINT_COST;
  String size_wide = inches_to_feet(displayinch_x);
  String size_high = inches_to_feet(displayinch_y);
  totals_area.setText(total_prints + " prints $" + cost + ", " + size_wide + "x" + size_high);
  
//  println("display size in inches: " + displayinch_x + " wide by " + displayinch_y + " high.");
//  println("number of prints needed: " + prints_wide + " wide and " + prints_high + " high.");
//  println("aspect ratio of image: " + (float)imagepx_x / (float)imagepx_y);
//  println("aspect ratio of display rectangle: " + (float)printpx_x / (float)printpx_y);  
}

void drawGrid() {
  stroke(color(255, 0, 0, 64));
  noFill();
  rectMode(CORNER);
  for(float x = imageorigin_x; x < imageorigin_x + screenpx_x; x += printpx_x) {
    for(float y = imageorigin_y; y < imageorigin_y + screenpx_y; y += printpx_y) {
      rect(x, y, printpx_x, printpx_y);
    }
  }
}


void load_image() {
  load_path = selectInput();
  if(load_path != null) {
    img = loadImage(load_path);
    calculate_image_scaling();
  }
}

void save_prints() {
  save_path = selectFolder();
  if(save_path != null) {
    String[] path_chunks = split(load_path, '\\');
    String filename = path_chunks[path_chunks.length - 1];
    // Start splitting the image into chunks and individually blowing up to print resolution and save to file
    float imgstepx = (float)printinch_x*(float)img.width/(float)displayinch_x;
    float imgstepy = (float)printinch_y*(float)img.height/(float)displayinch_y;
    int row, column;
    column = 0;
    for(float y = 0; y < (float)img.height; y += imgstepy) {
    row = 0;
      for(float x = 0; x < (float)img.width; x += imgstepx) {
        // Now we've found our origin/corner for the subrectangle of the image, we copy the pixels out
        // to a new image object we'll blow up into the print dimensions
        PImage imgchunk = ImgChunk(img, floor(x), floor(y), floor(imgstepx), floor(imgstepy));
        PImage printimage = createImage(ceil(DPI * printinch_x), ceil(DPI * printinch_y), RGB);
        printimage.copy(imgchunk, 0, 0, imgchunk.width, imgchunk.height, 0, 0, printimage.width, printimage.height);
        String printfilename = filename + "-" + str(prints_wide) + "x" + str(prints_high) + "-" + str(column) + "x" + str(row) + ".png";
        String savePathFull = save_path + "\\" + printfilename;
        printimage.save(savePathFull);
        column ++;
      }
      row ++;
    }    
  }
}

// o_O  O__o   o__O  O_o   o__O  O_o o__O O__o  o_O O__o   o_O     O__o 
PImage ImgChunk(PImage img, int cornerx, int cornery, int chunkwidth, int chunkheight) {
  PImage imgchunk = createImage(chunkwidth, chunkheight, RGB);
  img.loadPixels();
  imgchunk.loadPixels();
  for(int x = 0; x < chunkwidth; x++) {
    for(int y = 0; y < chunkheight; y++) {
      int imgoffsetx = x + cornerx;
      int imgoffsety = y + cornery;
      if((imgoffsetx < img.width) && (imgoffsety < img.height)) {
        imgchunk.pixels[y*imgchunk.width + x] = img.pixels[(y + cornery)*img.width + (x+cornerx)];
      }
      else {
        imgchunk.pixels[y*imgchunk.width + x] = color(255);
      }
    }
  }
  imgchunk.updatePixels();
  return imgchunk;
}

String inches_to_feet(int inches) {
  if(inches > 0) {
    int feet = inches/12;
    int remainder_inches = inches % 12;
    return feet + "'" + remainder_inches + "\"";
  }
  return "";
}
