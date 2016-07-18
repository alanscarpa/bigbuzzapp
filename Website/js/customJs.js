function writeNewPost() {
  // Get a key for a new article.
  var articleKey1 = firebase.database().ref().child('articles').push().key;
  var articleKey2 = firebase.database().ref().child('articles').push().key;

  var question = $('#question').val();
  var article1URL = $('#article1URL').val();
  var article1Title = $('#article1Title').val();
  var article1Lede = $('#article1Lede').val();
  var article1ThumbnailURL = $('#article1ThumbnailURL').val();
  var article2URL = $('#article2URL').val();
  var article2Title = $('#article2Title').val();
  var article2Lede = $('#article2Lede').val();
  var article2ThumbnailURL = $('#article2ThumbnailURL').val();

  var articleData1 = {
    lede: article1Lede,
    thumbnailURLString: article1ThumbnailURL,
    title: article1Title,
    urlString: article1URL
  };

  var articleData2 = {
    lede: article2Lede,
    thumbnailURLString: article2ThumbnailURL,
    title: article2Title,
    urlString: article2URL
  };

  var questionData = {
    yes: 0,
    no: 0,
    question: question,
    articles: [articleKey1, articleKey2]
  };

  var today = new Date();
  var dd = today.getDate();
  var mm = today.getMonth() + 1; //January is 0!
  var yyyy = today.getFullYear();
  if(dd<10){
      dd ='0'+dd
  } 
  if(mm < 10){
      mm='0'+mm
  } 
  var currentDate = mm+'-'+dd+'-'+yyyy;

  firebase.database().ref().child('questions/' + currentDate).once("value", function(snapshot) {
    var hasQuestionForCurrentDate = snapshot.exists();
      var updates = {};
      updates['/questions/' + currentDate] = questionData;
      updates['/articles/' + articleKey1] = articleData1;
      updates['/articles/' + articleKey2] = articleData2;
      firebase.database().ref().update(updates, function(error) {
        if (error) {
          alert("Data could not be saved." + error);
        } else {
          if (!hasQuestionForCurrentDate) {
            updateNumberOfQuestions()
          } else {
            alert("Question updated successfully.");
            location.reload();
          }
        }
      });
  });
}

function updateNumberOfQuestions() {
  firebase.database().ref().child('number-of-questions/amount').transaction(function(amount) {
    return amount+1;
  }, function(error, committed, snapshot) {
  if (error) {
    alert("Data could not be saved." + error);
  } else if (!committed) {
    alert("Data could not be saved1.");
  } else {
    alert("Question saved successfully.");
  }
  location.reload();
  });
}
