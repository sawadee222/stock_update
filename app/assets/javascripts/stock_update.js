document.addEventListener("DOMContentLoaded", () => {

    const loadingElement = document.getElementById("loader");
    const resultElement = document.getElementById("result");

    // 非同期通信が始まったときにローディングGIFを表示
    document.addEventListener("ajax:send", () => {
      resultElement.style.display = "none";
      loadingElement.style.display = "block";
    });
  
    // 非同期通信が完了したときにローディングGIFを非表示
    document.addEventListener("ajax:complete", () => {
      loadingElement.style.display = "none";
      resultElement.style.display = "block";
    });
  
    // 非同期通信が失敗したときもローディングGIFを非表示
    document.addEventListener("ajax:error", () => {
      loadingElement.style.display = "none";
      alert("通信エラーが発生しました");
    });
  });