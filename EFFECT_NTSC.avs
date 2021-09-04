#AviSynth Editing Script File - Made for AviSynth v2.58 (Might or might not work on other versions.)
#Drag this file into VirtualDub window.
#Commands in CAPITALS have notes/tips below.

#EXTERNAL FONT IS USED (Camcorder Monospaced)
#Download it from http://badmeangood.com/CAMCORDER_FONT_FAMILY/ -> Click "DOWNLOAD CAMCORDER FONT FAMILY (OPENTYPE)"
#In downloaded ZIP, locate this: CAMCORDER FONT FAMILY -> CAMCORDER MONOSPACED -> CAMCORDER_MS_REG.otf
#Extract and install CAMCORDER_MS_REG.otf font.

#If AVISOURCE below gives an error, use DirectShowSource or better yet, convert it into H.264/AVC or MPEG-4/ASP instead.
#Important! The video must contain an Audio stream!

#== VIDEO INPUT ==#

#SOURCEVIDEO: Your raw footage in AVI format (It should be encoded in H.264/AVC or MPEG-4/ASP)
#Note: You can omit file path if it is in the same folder as this file.

SOURCEVIDEO=DirectShowSource("bro_Xvid.avi").bilinearresize(392,480).resampleaudio(48000)


loss=imagesource("mask\hsync_%03d.bmp",end=127).assumefps(2997,100).loop(1000)

#ADDBORDERS of (32,20,32,20) is between title safe and action safe.
#use (8,0,8,0) for full image area. (4:3 Aspect Ratio source)
#use (8,80,8,80) for widescreen. (16:9 Aspect Ratio source)
original=converttorgb32(sourcevideo).LEVELS(0,1,255,4,200).ADDBORDERS(4,0,4,0).changefps(2997,100)
originalaudio=killvideo(sourcevideo)


#== GREYSCALE ==#

grey1=greyscale(original).bilinearresize(288,480).blur(-1,1).bicubicresize(400,480)
grey2=pointresize(grey1,800,480).crop(0,0,799,480).addborders(1,0,0,0).bilinearresize(400,480)

hsyncloss1=mergeARGB(showgreen(loss),showblue(loss),showblue(loss),showblue(loss)).pointresize(400,480)
hsyncloss2=invert(hsyncloss1,"A")
greysync1=layer(grey1,hsyncloss1)
greysync2=layer(grey2,hsyncloss2)
grey=overlay(greysync1,greysync2,mode="add",opacity=1).converttoyv12


#== COLOR ==#

#ADDBORDERS: How off-set is the chroma channel from luma (X,Y,0,0) X=Horizontally, Y=Vertically (Both Even Number)
colorinputu=original.bilinearresize(100,480).blur(1,0).bilinearresize(400,480).ADDBORDERS(4,2,0,0)

#For NTSC colour (Hue Tinting) "Never The Same Colours"
colorinputv=converttoyv12(colorinputu).coloryuv(cont_v=-160).converttorgb32


colorlossu=mergeARGB(showred(loss),showblue(loss),showblue(loss),showblue(loss)).pointresize(400,480)
colorlossv=trim(colorlossu,32,0)

coloru=layer(colorinputu,colorlossu).converttoyv12
colorv=layer(colorinputv,colorlossv).converttoyv12
color=mergechroma(coloru,colorv,0.5).coloryuv(gain_y=-256, cont_u=128, cont_v=128)


colorlossu=mergeARGB(showred(loss),showblue(loss),showblue(loss),showblue(loss)).pointresize(400,480)
colorlossv=trim(colorlossu,32,0)

coloru=layer(colorinputu,colorlossu).converttoyv12
colorv=layer(colorinputv,colorlossv).converttoyv12
color=mergechroma(coloru,colorv,0.5).coloryuv(gain_y=-256, cont_u=128, cont_v=128)


#== AUDIO ==#

#You can disable the options by putting # at the beginning of the commands below.
#Make sure you don't disable or enable them both! (Hi-Fi or Baseband Audio)


#For Baseband Audio (Default pick, no further work required on audio!)
audnoise=wavsource("hifi 3 artifect.wav").resampleaudio(48000).loop(600)

#Realistic: Equalization uses supereq. Normally use this:
vidaudio=converttomono(originalaudio).amplify(0.3).supereq("vhs.feq")

#Compatibility: If the above create error, use this instead: (Not realistic)
#vidaudio=converttomono(originalaudio).resampleaudio(16000).amplify(0.7).resampleaudio(48000)


#For Hi-Fi Audio (Not quite realistic for the Hi-Fi audio artifect...)
#audnoise=wavsource("hifi artifect.wav").loop(600)
#vidaudio=originalaudio

#Important! If the original audio is mono, use this instead:
#vidaudio=originalaudio


#For External audio, in case you can do an 80s tape effect, which can be more realistic)
#vidaudio=wavsource("[EXTERNAL AUDIO].wav").resampleaudio(48000)

#Use this to extract the original audio [VirtualDub: File -> Save WAV...]
#RETURN original


#== FINALIZING ==#

player=BLANKCLIP(length=60, color=$2222DD, fps=29.97, CHANNELS=1, audio_rate=48000).converttoyv12
#BLANKCLIP: Important! Set CHANNELS to 2 if you use Hi-fi audio or External Audio if it is in stereo. Else, set it to 1.


#Use this for Baseband or Hi-Fi Audio only.
finalaudio=mixaudio(vidaudio,audnoise,0.96,0.04)

#Use this if you use External Audio
#finalaudio=vidaudio

#Change "noise-preprocess.avi" to "noise-preprocess2.avi" for different VHS noise with colour stripes
noise=avisource("noisev2.avi").bilinearresize(400,480).loop(300)

finalsignal=overlay(grey, color, mode="add", opacity=1)

#If you want the VHS noise to be more visible, change "opacity" to equal 1
finalvideo=overlay(finalsignal, noise, mode="add", opacity=0.6).LEVELS(40,1,255,0,255).bilinearresize(640,480)

final=audiodub(finalvideo,finalaudio)


#== OUTPUT ==#
player+final


#If you don't want an OSD then disable these commands.
Subtitle("",48,24,10,160,"VCR OSD Mono",36,$DDDDDD)
Subtitle("",48,60,70,161,"VCR OSD Mono",36,$DDDDDD)
#SUBTITLE("         [HI-FI]",48,24,180,330,"Camcorder Monospaced",36,$DDDDDD)
#SUBTITLE in caps: Disable it if you use Baseband audio.


#== PREVIEWING ==#

#SELECTEVERY(3 ,0,2)
#SELECTEVERY(3,0)
#SELECTEVEN

#SELECTEVEN or SELECTEVERY: Enable if you want a smooth VirtualDub preview if it is freezing periodically. DISABLE before saving as AVI!