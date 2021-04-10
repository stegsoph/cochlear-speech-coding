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

function biphasic_pulse(N_total,N_pulse,N_period)
    N_repeat = convert(Int, ceil(N_total/N_period))
    x = range(0, 1, length = N_pulse)
    y = ones(size(x))
    y[abs.(x) .> 0.5] .= -1
    append!(y,zeros((N_period-N_pulse,1)))
    y = repeat(y,N_repeat,1)
    y = y[1:N_total]
    return y
end


""" writes a wav file to listen to in the specified folder """
function WAV.wavplay(x::AbstractArray,fs)
    path = "./tmp/a.wav"
    wavwrite(x,path,Fs=fs)
end