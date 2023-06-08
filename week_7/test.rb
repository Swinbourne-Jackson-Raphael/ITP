require 'gosu'

class AlbumPlayer < Gosu::Window
  def initialize(album)
    super(800, 600)
    self.caption = "Album Player"
    @font = Gosu::Font.new(20)

    @album = album
    @artwork = Gosu::Image.new("images/#{@album[:artwork]}")
    @tracks = @album[:tracks]
    @current_track_index = 0
    @current_track = nil

    play_track(@current_track_index)
  end

  def play_track(index)
    if @current_track
      @current_track.stop
    end

    track = @tracks[index]
    @current_track = Gosu::Song.new(self, "tracks/#{track[:location]}")
    @current_track.play(true)
  end

  def update
    if @current_track && !@current_track.playing?
      if @current_track_index < @tracks.length - 1
        @current_track_index += 1
        play_track(@current_track_index)
      end
    end
  end

  def draw
    @artwork.draw(200, 100, 0)

    info = "#{@album[:title]} - #{@album[:artist]}"
    @font.draw(info, 200, 300, 0)

    @tracks.each_with_index do |track, index|
      y = 350 + index * 30
      if index == @current_track_index
        track_info = "Now playing: #{track[:title]}"
        @font.draw(track_info, 200, y, 0)
      else
        @font.draw(track[:title], 200, y, 0)
      end
    end
  end

  def button_down(id)
    if id == Gosu::KB_ESCAPE || id == Gosu::KB_Q
      close
    end
  end
end


AlbumPlayer.new().show