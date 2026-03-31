---
id: email-summary-app-1772176056425
name: Email Summary App
type: task
---

**Prompt:**

I want to create a flutter app for Email Summary Agent 
in that I want login and Registration of users with email and password as well as Google Signup and Signin 
after successfull login user should go to Set prefrence screen where user should set prefrences like 
Summary Type:- "Daily/Weekly" if user select daily then only those email will get collected which are arrived in users inbox today "current data = email arrivel date". If user select the Weekly option the all the mails which are arrived in past seven days will be collected. 
Email Filter:- "All/Unreaded/Stared" in this we will apply the filter on all collect images by checking if they are unreaded or stared if user select all the all emails will be selected for summarization, if user select Unreaded then only Unreaded emails from all collected emails will be selected for summarization, if user selected Stared then only stared emails will be selected for summarization and other mails will be removed from collected mails.
Number of Emails:- This is the count of email which will be summaried at a time "if user will enter 5" then all the collect email will be divied in to batch of  5 emails/batch. 
then these batches will get summarized one by one. 
Summary Style:- "Formal/Casual/ Bullet Points" in this user will set the format of the summary generation if user will select the Formal then user will get the summary generated in formal format. if user will select the Casual then user will get the summary in casual format and if user will select the Bullet points then the summary will be generated in Bullet point format. 
Delivery Methods:- "In App/ In Indox" this give choice to user where they want to see or read their Generated Summary . If user select" in App" then user can reade summary in app itself, if user select "in Indox" then all the generated summarys will be displayed in app as well as in the user will get the mail for generated summaries to their registered email id. 
After successfull selecting and storing all the users prefrence data in firebase 
we will navigate user to home page where user can see a card in that user emails profile img, username, email id and last summarized date "if user uses app for first time then show "not summazied yet", below the card we will show a "Generate Summary with AI" button on its click our ai agent "gemini 2.5" will collect all the data and generate the summary of the users mail will be generated according to user prefrences such as "Summary type, Email Filters, Number of Emails, Summary Style, DeliveryMethods", after the successful summary generation, all the generated summaries will be stored in firebase then we will add a button "View Summary Button" on its click user will navigate to "Summary Page"  where the all  summarys of all batch will be dispayed in card format with a tag of "readed/ unreaded" initially all the summarys cards are unreaded tags when user click on that card user will navigateto summary detail page where user can read the generated summary and at the end of summary thir will be a button "Mark it readed" when user click on this button then the unreaded tag should change to readed. 
all the generated summery will be stored and showed in History Page where user can search previous generated summaries according to dates all the generated summaries will be shown in this page in card formats so that user can click on that card and read it again. 
we will add a profile page for users where user will see all the information provided my users while login and registration also we will display the prefrences data user can modify their prefrences from profile page, at the bottom of the profile page we will add a logout button so that user will logout and navigate to login page. 
we will add a splash screen where we will check if user has account if user has then well send it to home, or else to login page
add a bottom navbar for easier navigation 
add a morden and unique, user friendly Ui for the app


