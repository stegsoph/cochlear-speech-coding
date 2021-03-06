""" plot a spectrogram """
function plot_spectrogram(s, fs; t_window::Float64 = 25e-3, t_overlap ::Float64=10e-3)
    S = spectrogram(s[:,1], convert(Int, round(t_window*fs)),
                    convert(Int, round(t_overlap*fs)); window=hanning)
    t = S.time
    f = S.freq
    imshow(reverse(log10.(S.power), dims = 1), extent=[first(t)/fs, last(t)/fs,
             fs*first(f)/1000, fs*last(f)/1000], aspect="auto", cmap="jet", vmin=1, vmax=-15)
    xlabel("Time in s")
    ylabel("Frequency in kHz")
    cbar = colorbar()
    cbar.set_label("dB")
end;

""" plot a spectrogram - subplot """
function plot_spectrogram_subplot(s, fs,ax; t_window::Float64 = 25e-3, t_overlap ::Float64=10e-3,title="")
    S = spectrogram(s[:,1], convert(Int, round(t_window*fs)),
                    convert(Int, round(t_overlap*fs)); window=hanning)
    t = S.time
    f = S.freq
    ax.imshow(reverse(log10.(S.power), dims = 1), extent=[first(t)/fs, last(t)/fs,
             fs*first(f)/1000, fs*last(f)/1000], aspect="auto", cmap="jet")
    ax.set_title(title)
    ax.set_xlabel("Time in s")
    ax.set_ylabel("Frequency in kHz")
end;

""" plot a time signal """
function plot_audio(time,signal)
    plot(time,signal)
    xlim([first(time),last(time)])
    xlabel("Time in s") 
    ylabel("Amplitude") 
end;


""" plot a time signal """
function plot_audio_subplot(time,signal,ax;title="")
    ax.plot(time,signal)
    ax.set_xlim([first(time),last(time)])
    ax.set_xlabel("Time in s") 
    ax.set_ylabel("Amplitude") 
    ax.set_title(title)
end;



""" create an electrode plot"""
function plot_electrode(N_electrodes,time,electrode_signal;xlim_low=0,xlim_up=last(time),title="Electrode plot")
    figure(figsize=(8,8))
    ax = [plt.subplot(N_electrodes,1,i) for i in (1:N_electrodes)]
    ax[1].set_title(title)

    colors = ["royalblue", "crimson"]
    for (i,a) in enumerate(ax)
        if a != last(ax)
            a.set_xticklabels([])
        end
        #a.set_ylim([-0.01,0.01])
        a.set_yticklabels([])
        a.set_yticks([])
        a.plot(time,electrode_signal[N_electrodes+1-i,:], color = colors[mod1(N_electrodes+1-i,2)])
        a.set_xlim([xlim_low,xlim_up])
        a.set_ylabel(string(N_electrodes+1-i))
    end
    last(ax).set_xlabel("Time in s")
    for i in 2:N_electrodes
        down_side = ax[i-1].spines["bottom"]
        down_side.set_visible(false) 
        up_side = ax[i].spines["top"]
        up_side.set_visible(false) 
    end
    plt.subplots_adjust(wspace=0, hspace=0)
end;


""" create an electrode subplot """
function plot_electrode_subplot(N_electrodes,time,electrode_signal,ax;xlim_low=0,xlim_up=last(time),title="Electrode plot",N_yticks=5)
    #ax = [plt.subplot(N_electrodes,1,i) for i in (1:N_electrodes)]
    ax[1].set_title(title)

    colors = ["royalblue", "crimson"]
    for (i,a) in enumerate(ax)
        if a != last(ax)
            a.set_xticklabels([])
        end

        a.plot(time,electrode_signal[N_electrodes+1-i,:], color = colors[mod1(N_electrodes+1-i,2)])
        a.set_xlim([xlim_low,xlim_up])
        a.set_yticklabels([])
        a.set_yticks([])

        if (mod(N_electrodes+1-i,N_yticks)==0)
            a.set_ylabel(string(N_electrodes+1-i))
        else
            a.set_ylabel("")
        end

    end
    last(ax).set_xlabel("Time in s")
    for i in 2:N_electrodes
        down_side = ax[i-1].spines["bottom"]
        down_side.set_visible(false) 
        up_side = ax[i].spines["top"]
        up_side.set_visible(false) 
    end
    plt.subplots_adjust(wspace=0, hspace=0)
end;