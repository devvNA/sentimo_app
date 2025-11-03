# Project Name: Sentimo: The AI Sentiment Journal

## Description
Sentimo is a minimalist daily diary app designed to assist individuals in tracking their emotional health by automatically analyzing the sentiment of journal entries using AI. It leverages Flutter for its frontend, Supabase for backend and data storage, and BloC for state management.

## Primary Goals
- Provide a seamless journaling experience with automatic sentiment analysis.
- Enable users to track and reflect on their emotional patterns over time effortlessly.
- Ensure a modern and calming UI/UX to enhance user engagement and satisfaction.

----------------------------------------------------

## Tech Stack & Environment

**Frontend:** Flutter

**Backend:** Supabase (PostgreSQL + Auth)

**Target Platform:** Mobile Application

**Framework Versions & Config:** Latest stable versions

----------------------------------------------------

## Requirements & Features

### Core Features:
- User authentication using Supabase Auth.
- Home page displaying a list of journal entries.
- Dedicated page for creating and saving journal entries.
- Automatic sentiment analysis using the Google Gemini API.

### User Flows
1. User registers or logs in using Supabase Auth.
2. User navigates to the home page displaying their journal entries.
3. User creates a new journal entry, writes, and saves it.
4. AI analyzes the entry and assigns a sentiment label.
5. User views the sentiment analysis feedback and can track mood history.

### Business Rules
- Users must be authenticated to create, view, or edit journal entries.
- Sentiment analysis is triggered automatically upon saving a journal entry.
- Sentiment labels should be stored alongside journal entries in the database.

----------------------------------------------------

## UI/UX Design

### Layout
- Use a bottom navigation bar for easy access to different sections (Home, New Entry, Profile).
- Responsive design to ensure usability across various screen sizes.

### Look & Feel
- Modern, clean, and minimalist design.
- Calming color palette: soft blue, mint green, off-white, and dark gray.
- Typography: modern, readable sans-serif font.

### Pages
- Login/Register Page
- Home Page with Journal List
- New Entry Page for writing journals

### Components
- Navigation Bar
- Journal Entry Card
- Sentiment Feedback Indicator

----------------------------------------------------

## Data Model & Supabase Setup

### Database Schema
- Users Table: id, username, email, password_hash
- Journal Entries Table: id, user_id, content, sentiment_label, created_at

### Row-Level Security
Enabled by default

### Auth Requirements
- Supabase Auth to manage user sessions and secure access to journal entries.
