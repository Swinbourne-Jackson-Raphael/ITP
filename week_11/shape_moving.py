# Acknowledgement to the original authors of the code on which this 
# example is based.
import pygame

pygame.init()

SCREEN_HEIGHT = 400
SCREEN_WIDTH = 400

screen = pygame.display.set_mode((SCREEN_WIDTH, SCREEN_HEIGHT))
done = False
is_blue = True
x = 30
y = 30

time = pygame.time

while not done:
        for event in pygame.event.get():
                if event.type == pygame.QUIT:
                        done = True
                if event.type == pygame.KEYDOWN and event.key == pygame.K_SPACE:
                        is_blue = not is_blue
        
        pressed = pygame.key.get_pressed()

        # Inputs
        if pressed[pygame.K_LEFT]: x -= 0.1
        if pressed[pygame.K_RIGHT]: x += 0.1
        if pressed[pygame.K_UP]: y -= 0.1
        if pressed[pygame.K_DOWN]: y += 0.1

        # Screen Contraints
        if x > SCREEN_WIDTH - 60: x = SCREEN_WIDTH - 60
        if x < 0: x = 0
        if y > SCREEN_HEIGHT - 60: y = SCREEN_HEIGHT - 60
        if y < 0: y = 0
        

        screen.fill((0, 0, 0))
        if is_blue: color = (0, 128, 255)
        else: color = (255, 100, 0)

        rect = pygame.Rect(x, y, 60, 60)
        pygame.draw.rect(screen, color, rect)

        pygame.display.flip()
