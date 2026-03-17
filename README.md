# Microcomputer System Project 2 - 8051 Music Player

這是一個基於 8051 微處理器組合語言 (Assembly) 開發的音樂播放專案。透過控制 8051 晶片上的 Timer0 和 Timer1，能夠播放預先定義好的特定頻率音符 (Notes) 和節拍 (Tempo)，並透過蜂鳴器 (Buzzer) 輸出音樂。

## 專案結構與檔案說明 (Project Structure)

* `project_2_upload/Project_2.Note_Tempo.asm`: 專案核心原始碼（8051 組合語言）。包含了音階頻率與節拍計算的控制邏輯。
* `project_2_upload/8051_Project_design.xlsx`: 專案設計階段的相關規格與參數對照表（例如音符與計數值換算表）。
* `project_2_upload/微電腦系統Projecct-2.pptx`: 專案期末報告簡報，包含設計理念與架構圖。
* `project_2_upload/demo_video.mp4`: 最終專案成果展示影片。
* `discussion video/`: 包含各階段開發與測試過程的討論及測試影片（如 `同時兩個音_0.25ms.mp4` 等）。

## 系統設計與運作原理 (System Design & Principles)

此專案主要利用 8051 的兩組計時器（Timers）運作：
1. **Timer 0 (Mode 1)**: 負責控制 **音符頻率 (Note/Pitch)**。
   - 根據不同音符的頻率，計算出相對應的延遲時間 (Delay 半週期)。
   - 將換算出來的 Count 值寫入 `TH0` 和 `TL0`，透過反轉 `P3.4` (Buzzer) 腳位產生指定頻率的方波來發聲。
2. **Timer 1 (Mode 1)**: 負責控制 **節拍長度 (Tempo/Duration)**。
   - 以 $\approx 0.857$ 秒為一拍，將 Timer 1 搭配 `DJNZ` 迴圈來延伸計時長度，藉此達成整拍、半拍或不同長度的音符與休止符時間控制。

## 開發與執行 (How to Run)

這個專案需要搭配 8051 開發板及 IDE（例如 Keil C51 或類似的組合語言組譯器）進行編譯。
1. 將 `Project_2.Note_Tempo.asm` 加入您的 8051 專案。
2. 建置 (Build/Compile) 出 `.hex` 燒錄檔。
3. 將 `.hex` 檔燒錄至 8051 開發版（系統時脈設定約為 11.0592 MHz）。
4. 接上 Buzzer 於 `P3.4` 腳位，即可聽到程式定義好的音樂。