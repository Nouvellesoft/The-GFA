const {onSchedule} = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");
const axios = require("axios");
require('dotenv').config();


admin.initializeApp();

// Define Player Subcollections
const playerSubcollections = [
  "FirstTeamClassPlayers",
  "SecondTeamClassPlayers",
  "ThirdTeamClassPlayers",
  "FourthTeamClassPlayers",
  "FifthTeamClassPlayers",
  "SixthTeamClassPlayers",
];

// Function to check if a date matches today
function isBirthdayToday(dobString) {
  if (!dobString) {
    console.log("Skipping player with missing DOB");
    return false;
  }

  const today = new Date();
  const currentDay = today.getDate();
  const currentMonthName =
  today.toLocaleString("default", {month: "long"}).toUpperCase();

  // Parse the stored DOB
  const matches = dobString.match(/(\d+)(?:ST|ND|RD|TH)\s+([A-Z]+)/);

  if (matches) {
    const storedDay = parseInt(matches[1]);
    const storedMonth = matches[2];

    return storedDay === currentDay && storedMonth === currentMonthName;
  }

  console.log(`Invalid DOB format for ${dobString}`);
  return false;
}

// Cloud Function to Send Birthday Notifications
exports.sendBirthdayNotifications =
onSchedule("every day 08:30", async (event) => {
  const db = admin.firestore();
  const messaging = admin.messaging();

  try {
    const clubsSnapshot = await db.collection("clubs").get();
    if (clubsSnapshot.empty) {
      console.log("No clubs found.");
      return;
    }

    for (const clubDoc of clubsSnapshot.docs) {
      const clubName = clubDoc.id;

      for (const subcollection of playerSubcollections) {
        const playersSnapshot = await db
          .collection("clubs")
          .doc(clubName)
          .collection(subcollection)
          .get();

        const birthdayPlayers = playersSnapshot.docs.filter((playerDoc) =>
          isBirthdayToday(playerDoc.data().d_o_b),
        );

        if (birthdayPlayers.length === 0) {
          console.log(`No birthdays today in ${subcollection} of ${clubName}.`);
          continue;
        }

        for (const playerDoc of birthdayPlayers) {
          const playerDetails = playerDoc.data();
          const playerNameSubcollection = playerDetails.name.toLowerCase();

          const playersTableSnapshot = await db
            .collection("clubs")
            .doc(clubName)
            .collection("PllayersTable")
            .get();

          let matchedPlayer = null;

          playersTableSnapshot.docs.forEach((statsDoc) => {
            const stats = statsDoc.data();
            const playerNameTable = stats.player_name.toLowerCase();

            if (playerNameSubcollection === playerNameTable) {
              matchedPlayer = stats;
            }
          });

          if (matchedPlayer) {
            const player = {
              name: matchedPlayer.player_name ||
              playerDetails.name || "Unknown Player",
              goals: matchedPlayer.goals_scored || 0,
              assists: matchedPlayer.assists || 0,
              matchesPlayed: matchedPlayer.matches_played || 0,
              yellowCards: matchedPlayer.yellow_card || 0,
              redCards: matchedPlayer.red_card || 0,
              image: matchedPlayer.image || playerDetails.image || "",
            };

            console.log(`🎊 Passing 
              ${player.name},  in ${subcollection}, in ${clubName}`);

            const {title, body} = await generateBirthdayMessage(player);

            const payload = {
              notification: {
                title: title || "🎉 Happy Birthday!",
                body: body || `${player.name}, 
                shine like a star on your special day!`,
                image: player.image || "",
              },
              data: {
                type: "BIRTHDAY_NOTIFICATION",
                clubId: clubName,
                playerName: player.name,
                subcollection: subcollection,
              },
              topic: clubName,
            };

            try {
              await messaging.send(payload);
              console.log(`🎊 Notification sent for 
                ${player.name} in ${clubName}`);
            } catch (error) {
              console.error("❌ Error sending notification:", error);
            }
          } else {
            console.log(`No matching stats found for 
              ${playerNameSubcollection} in ${clubName}.`);
          }
        }
      }
    }
  } catch (error) {
    console.error("💥 Overall function error:", error);
  }
});

// Function to Generate AI Birthday Message
async function generateBirthdayMessage(player) {
  const prompt = `Write a short, funny birthday message under 15 words` +
  ` for ${player.name}. The player has ${player.goals} goals,` +
    ` ${player.assists} assists, ${player.matchesPlayed} matches played,` +
    ` ${player.yellowCards} yellow cards, and ${player.redCards} red cards.` +
    ` Make it light-hearted, football-themed, and creative.`;

  try {
    const response = await axios.post(
      "https://api.openai.com/v1/chat/completions",
      {
        model: "gpt-3.5-turbo",
        messages: [{"role": "user", "content": prompt}],
        max_tokens: 50,
        temperature: 0.7,
      },
      {
        headers: {
          "Authorization": `Bearer ${process.env.OPENAI_API_KEY}`,
          "Content-Type": "application/json",
        },
      },
    );

    const message = response.data.choices[0].message.content.trim();

    // Split using '.' or '!' as delimiters
    let [title, ...body] = message.split(/[.!]/);

    // Handle cases where body is empty
    if (!body.length) {
      body = [title];
      title = "🎉 Happy Birthday!";
    }

    return {title: title.trim(), body: body.join(".").trim()};
  } catch (error) {
    console.error("⚠️ AI Message Error:", error.response ?
      error.response.data : error);
    return {
      title: "🎉 Happy Birthday!",
      body: `${player.name}, you're a football star today!`,
    };
  }
}
