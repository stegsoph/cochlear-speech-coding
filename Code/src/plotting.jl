""" plot a spectrogram """
function plot_spectrogram(s, fs; t_window::Float64 = 25e-3, t_overlap ::Float64=10e-3)
    S = spectrogram(s[:,1], convert(Int, round(t_window*fs)),
                    convert(Int, round(t_overlap*fs)); window=hanning)
    t = S.time
    f = S.freq
    imshow(reverse(log10.(S.power), dims = 1), extent=[first(t)/fs, last(t)/fs,
             fs*first(f), fs*last(f)], aspect="auto", cmap="jet", vmin=1, vmax=-15)
    xlabel("Time in s")
    ylabel("Frequency in Hz")
    cbar = colorbar()
    cbar.set_label("dB")
end;

""" plot a time signal """
function plot_audio(time,signal)
    plot(time,signal)
    xlim([first(time),last(time)])
    xlabel("Time in s") 
    ylabel("Amplitude") 
end;
