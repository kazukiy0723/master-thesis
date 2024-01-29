%% 2Channnelの遅延時間の測定
% チャンネル1: 小型マイク　チャンネル2: アプリ
clear all

filename = 'delayTime_test2.csv'; % 出力先ファイル
fs = 48000; % サンプリング周波数[Hz]
nbits = 16; %  量子ビット数
nChannel = 2; % チャンネル数
buffer = 10000; % 標準偏差を算出するときのサンプル数
length_record = 5; % 録音時間[s]

recorder = audiorecorder(fs, nbits, nChannel);

% length_record秒間録音
recordblocking(recorder, length_record); 

% 配列の取得
myRecording = getaudiodata(recorder);

% チャネル1とチャネル2を分割
channel1 = myRecording(:, 1);
if(nChannel == 2)
    channel2 = myRecording(:, 2);
end

% index2の計算
analyzed_segment = channel2(1000:6000);
mean_val = mean(analyzed_segment);
std_val = std(analyzed_segment);
%threshold2 = mean_val + 2 * std_val;
threshold2 = 0.2;
index2 = find(abs(channel2) > threshold2); % チャンネル2で閾値を超える最初の点を見つける

try
    % index2からbuffer点前までの信号を切り取る
    start = max(1, index2(1)-buffer);  
    data_to_analyze = channel1(start:index2(1)-1);

    % index1の計算
    mean_val1 = mean(data_to_analyze);
    std_val1 = std(data_to_analyze);
    threshold1 = 2 * std_val1;
    % 平均+2標準偏差を初めて超えた点をindex1とする
    index1 = find(abs(data_to_analyze) > threshold1, 1) + start - 1;

    % 表示
    time = (1/fs) * (0:length(channel1)-1) * 1000;
    Channel1_ExceedTime = time(index1);
    fprintf("Channel.1: %f\r\n", Channel1_ExceedTime);

    if(nChannel == 2)
        Channel2_ExceedTime = time(index2(1));
        fprintf("Channel.2: %f\r\n", Channel2_ExceedTime);
        delayTime = Channel2_ExceedTime - Channel1_ExceedTime;
        fprintf("Delay: %f\r\n", delayTime);

        % CSVファイルへの書き込み（追記）
        writematrix(delayTime, filename, 'WriteMode', 'append');

    end
catch
    disp('エラー');
    return;
end

% グラフ描画
figure(1); 
plot(time, channel1);
hold on;
plot(time, channel2);
line([Channel1_ExceedTime, Channel1_ExceedTime], ylim, 'Color', 'g', 'LineStyle', '--', 'LineWidth', 2);
line([Channel2_ExceedTime, Channel2_ExceedTime], ylim, 'Color', 'b', 'LineStyle', '--', 'LineWidth', 2);
% 軸ラベルとタイトルの設定
xlabel('Time [ms]', 'FontSize', 20);  % X軸ラベル
ylabel('Amplitude', 'FontSize', 20);  % Y軸ラベル
%title('Channel 1 and Channel 2', 'FontSize', 16);  % タイトル

% 凡例の設定
legend('Channel 1','Channel 2', 'FontSize', 20);

% 軸のフォントサイズの設定
ax = gca;  % 現在の軸を取得
ax.FontSize = 16;  % 軸のフォントサイズを設定

hold off;
