<<<<<<< HEAD
# first example of drawing on the canvas

import simplegui
count=0
pos_x=100
pos_y=100
size_x=300
size_y=200
count=size_x

# define draw handler
def draw(canvas):
    global count, pos_x,pos_y,size_x,size_y
    count-=1
    pos_x = size_x - (count % size_x)
    
    canvas.draw_text("Hello!",[pos_x, pos_y], 24, "White")
    canvas.draw_circle([100, 100], 2, 2, "Red")

# create frame
frame = simplegui.create_frame("Text drawing", size_x,size_y)

# register draw handler    
frame.set_draw_handler(draw)

# start frame
frame.start()
=======
# first example of drawing on the canvas

import simplegui
count=0
pos_x=100
pos_y=100
size_x=300
size_y=200
count=size_x

# define draw handler
def draw(canvas):
    global count, pos_x,pos_y,size_x,size_y
    count-=1
    pos_x = size_x - (count % size_x)
    
    canvas.draw_text("Hello!",[pos_x, pos_y], 24, "White")
    canvas.draw_circle([100, 100], 2, 2, "Red")

# create frame
frame = simplegui.create_frame("Text drawing", size_x,size_y)

# register draw handler    
frame.set_draw_handler(draw)

# start frame
frame.start()
>>>>>>> e55f97114d0da06a25cf60393f67b0e16521bd92
