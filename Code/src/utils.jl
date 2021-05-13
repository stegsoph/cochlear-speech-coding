"""returns the number of times that the value changes its sign"""
function zero_crossings(array::AbstractVector{T}, size::Int = length(array), offset::Int = 0) where {T<:Real}
    result = 0
    previous = 0
    for i in offset .+ (1:size)
        number = array[i]
        sgn = number == 0 ? 0 : number > 0 ? 1 : -1
        if sgn != previous
            result += 1
        end
        previous = sgn
    end
    result
end;

""" From zero_crossings to frequency """
function freq_est_ZC(array,Fs)
    ZCR = zero_crossings(convert(Array{Float64,1}, array))
    f_est = ZCR/length(array)*Fs/2
    return f_est
end;

"""splits an array into overlapping frames"""

function generate_frames(signal,Fs)
    
    frame_size = 25e-3
    frame_stride = 10e-3

    frame_length, frame_step = frame_size * Fs, frame_stride * Fs  # Convert from seconds to samples

    signal_length = length(signal)
    frame_length = convert(Int, round(frame_length))
    frame_step = convert(Int, round(frame_step))
    num_frames = convert(Int, ceil(convert(Float64, abs.(signal_length - frame_length)) / frame_step))  # Make sure that we have at least 1 frame

    pad_signal_length = num_frames * frame_step + frame_length
    z = zeros((pad_signal_length - signal_length))
    pad_signal = []
    append!(pad_signal, signal, z)

    indices1 = transpose( repeat(collect(0 : frame_length-1), outer = [1,num_frames]) )
    indices2 = repeat(collect(1 : frame_step : num_frames * frame_step), outer=[1,frame_length] )
    indices = indices1 + indices2
    frames = pad_signal[indices]
    return frames
    
end;


""" pre-emphasis of a signal """

function pre_emph(signal)
    pre_emphasis = 0.97
    emphasized_signal = []
    test = signal[2:end] - pre_emphasis * signal[1:end-1]
    append!(emphasized_signal, signal[1], test) 
    emphasized_signal = Float64.(emphasized_signal);
    return emphasized_signal
end


""" generates biphasic pulses """

function biphasic_pulse(N_total,N_pulse,N_period;offset::Int64 = 0)
    N_repeat = convert(Int, ceil(N_total/N_period))

    x = range(0, 1, length = N_pulse)
    y = ones(size(x))

    y[abs.(x) .> 0.5] .= -1
    # append!(y,zeros((N_period-N_pulse,1)))
    y = [zeros((offset,1));y;zeros((N_period-N_pulse-offset,1))]
    y = repeat(y,N_repeat,1)
    y = y[1:N_total]
    return y
end


""" writes a wav file to listen to in the specified folder """
function WAV.wavplay(x::AbstractArray,fs)
    path = "./tmp/a.wav"
    wavwrite(x,path,Fs=fs)
end


""" pulse generation with N electrodes """

function pulse_generation(Fs,PulseRate,ElectrodeRate,Envelope,N_electrodes;f_low=1e3,f_high=4e3)

    pulses = []
    electrodes = []

    N_signal = length(Envelope)
    number_frames = size(PulseRate)[1]

    N_total = convert(Int,ceil(N_signal/number_frames))
    N_period_vec = convert.( Int, round.( Fs ./ PulseRate ) )
    N_pulse = convert(Int, round(1e-3 * Fs))

    delta_freq = (f_high-f_low)/(N_electrodes)
    frequency_spacing = collect( range(f_low+delta_freq, f_high, length = N_electrodes) );
    electrode_signal = zeros(N_electrodes,N_signal)

    for idx_frame in 1:number_frames
        
        idx_begin = (idx_frame-1)*N_total+1 
        idx_end = min(N_signal,idx_begin+N_total-1)
        idx_diff = idx_end-idx_begin
          
        N_period = N_period_vec[idx_frame]
        pulse_frame = biphasic_pulse(N_total,N_pulse,N_period)
        pulse_frame = Envelope[idx_begin : idx_end].*pulse_frame[1:idx_diff+1]
        
        append!(pulses, pulse_frame) 
        
        number_electrode = findall( ElectrodeRate[idx_frame] .<= frequency_spacing )
        append!(electrodes, minimum( number_electrode ) )

        electrode_signal[minimum( number_electrode ) , idx_begin : idx_end] = pulse_frame
        
    end

    return electrode_signal,electrodes,pulses,frequency_spacing

end