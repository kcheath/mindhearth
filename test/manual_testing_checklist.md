# 📱 Manual Testing Checklist

## 🎯 **Purpose**

This checklist ensures all critical user flows work correctly after backend changes. Use this for manual testing when automated tests pass but you want to verify the complete user experience.

## 🚀 **Quick Start**

1. **Start the app**: `flutter run`
2. **Follow this checklist**: Check off each item as you test
3. **Report issues**: Note any failures or unexpected behavior

## 🔐 **Authentication Flow**

### **Login Tests**
- [ ] **Valid Login**
  - [ ] Open app
  - [ ] Enter test credentials: `test@tsukiyo.dev` / `testpass123`
  - [ ] Tap "Login" button
  - [ ] Verify successful login
  - [ ] Check navigation to main app
  - [ ] Verify user info displayed correctly

- [ ] **Invalid Login**
  - [ ] Enter invalid credentials
  - [ ] Tap "Login" button
  - [ ] Verify error message displayed
  - [ ] Verify app doesn't crash
  - [ ] Verify user stays on login page

- [ ] **Login Loading State**
  - [ ] Enter valid credentials
  - [ ] Tap "Login" button
  - [ ] Verify loading indicator appears
  - [ ] Verify loading indicator disappears after login

### **Logout Tests**
- [ ] **Successful Logout**
  - [ ] Login successfully
  - [ ] Navigate to logout option
  - [ ] Tap logout
  - [ ] Verify return to login page
  - [ ] Verify user data cleared

## 💬 **Session Management**

### **Session Loading**
- [ ] **Load Sessions**
  - [ ] Login successfully
  - [ ] Navigate to sessions page
  - [ ] Verify sessions list loads
  - [ ] Verify no loading errors
  - [ ] Verify sessions display correctly

- [ ] **Empty Sessions**
  - [ ] If no sessions exist
  - [ ] Verify empty state message
  - [ ] Verify "Create Session" option available

### **Session Creation**
- [ ] **Create New Session**
  - [ ] Tap "Create Session" or "+" button
  - [ ] Enter session name
  - [ ] Tap "Create" button
  - [ ] Verify session created successfully
  - [ ] Verify session appears in list
  - [ ] Verify session is selected automatically

- [ ] **Create Session with Minimal Data**
  - [ ] Create session with just default name
  - [ ] Verify session created successfully
  - [ ] Verify default values applied

### **Session Selection**
- [ ] **Switch Between Sessions**
  - [ ] Create multiple sessions
  - [ ] Tap on different session
  - [ ] Verify session switches
  - [ ] Verify chat history loads for selected session
  - [ ] Verify session name updates in header

- [ ] **Session Persistence**
  - [ ] Select a session
  - [ ] Navigate away and back
  - [ ] Verify same session still selected
  - [ ] Verify session data persists

## 🤖 **Chat Functionality**

### **Message Sending**
- [ ] **Send Text Message**
  - [ ] Select a session
  - [ ] Type a message
  - [ ] Tap send button
  - [ ] Verify message appears in chat
  - [ ] Verify message is sent to backend
  - [ ] Verify response received (if backend responds)

- [ ] **Send Voice Message**
  - [ ] Tap microphone button
  - [ ] Grant microphone permission
  - [ ] Record a message
  - [ ] Stop recording
  - [ ] Verify voice message sent
  - [ ] Verify transcription appears

### **Message History**
- [ ] **Load Message History**
  - [ ] Select a session with existing messages
  - [ ] Verify previous messages displayed
  - [ ] Verify message order is correct
  - [ ] Verify timestamps displayed

- [ ] **Message Persistence**
  - [ ] Send a message
  - [ ] Navigate away and back
  - [ ] Verify message still there
  - [ ] Verify message history intact

### **Chat Features**
- [ ] **Typing Indicators**
  - [ ] Start typing a message
  - [ ] Verify typing indicator appears
  - [ ] Stop typing
  - [ ] Verify indicator disappears

- [ ] **Message Status**
  - [ ] Send a message
  - [ ] Verify message status (sending, sent, delivered)
  - [ ] Verify status updates correctly

## 🎨 **UI/UX Testing**

### **Navigation**
- [ ] **Page Navigation**
  - [ ] Login page → Main app
  - [ ] Main app → Sessions page
  - [ ] Sessions page → Chat page
  - [ ] Chat page → Settings (if available)
  - [ ] Back navigation works correctly

- [ ] **Navigation Guards**
  - [ ] Try to access chat without login
  - [ ] Verify redirect to login page
  - [ ] Login and verify access granted

### **Loading States**
- [ ] **App Launch**
  - [ ] Launch app
  - [ ] Verify loading screen appears
  - [ ] Verify loading completes within 5 seconds
  - [ ] Verify smooth transition to main content

- [ ] **API Loading**
  - [ ] Perform actions that require API calls
  - [ ] Verify loading indicators appear
  - [ ] Verify loading indicators disappear
  - [ ] Verify no infinite loading states

### **Error Handling**
- [ ] **Network Errors**
  - [ ] Disconnect internet
  - [ ] Try to send message
  - [ ] Verify error message displayed
  - [ ] Reconnect internet
  - [ ] Verify functionality restored

- [ ] **API Errors**
  - [ ] Trigger API errors (if possible)
  - [ ] Verify error messages displayed
  - [ ] Verify app doesn't crash
  - [ ] Verify retry options available

## 📱 **Device Testing**

### **Different Screen Sizes**
- [ ] **Phone Portrait**
  - [ ] Test on phone in portrait mode
  - [ ] Verify all elements visible
  - [ ] Verify touch targets appropriate size
  - [ ] Verify scrolling works correctly

- [ ] **Phone Landscape**
  - [ ] Test on phone in landscape mode
  - [ ] Verify layout adapts correctly
  - [ ] Verify chat input accessible
  - [ ] Verify keyboard doesn't cover content

- [ ] **Tablet**
  - [ ] Test on tablet (if available)
  - [ ] Verify layout scales appropriately
  - [ ] Verify touch targets appropriate
  - [ ] Verify content doesn't look stretched

### **Performance**
- [ ] **App Responsiveness**
  - [ ] Verify app responds to touch immediately
  - [ ] Verify no lag during navigation
  - [ ] Verify smooth animations
  - [ ] Verify no memory leaks (app doesn't slow down over time)

- [ ] **Battery Usage**
  - [ ] Monitor battery usage during testing
  - [ ] Verify reasonable battery consumption
  - [ ] Verify no excessive background activity

## 🔧 **Backend Integration**

### **API Connectivity**
- [ ] **Health Check**
  - [ ] Verify app can connect to backend
  - [ ] Verify API endpoints respond
  - [ ] Verify authentication works
  - [ ] Verify data synchronization

### **Data Consistency**
- [ ] **Session Data**
  - [ ] Create session in app
  - [ ] Verify session appears in backend
  - [ ] Verify session data matches
  - [ ] Verify session updates sync

- [ ] **Message Data**
  - [ ] Send message in app
  - [ ] Verify message stored in backend
  - [ ] Verify message content matches
  - [ ] Verify message order preserved

### **Real-time Features**
- [ ] **Live Updates**
  - [ ] Test real-time message delivery
  - [ ] Test session updates
  - [ ] Test user status updates
  - [ ] Verify updates appear without refresh

## 🚨 **Error Scenarios**

### **Network Issues**
- [ ] **No Internet**
  - [ ] Disconnect from internet
  - [ ] Try to use app
  - [ ] Verify appropriate error message
  - [ ] Verify app doesn't crash
  - [ ] Reconnect and verify functionality restored

- [ ] **Slow Internet**
  - [ ] Use slow internet connection
  - [ ] Verify app handles slow responses
  - [ ] Verify loading states appropriate
  - [ ] Verify timeout handling

### **Backend Issues**
- [ ] **Backend Down**
  - [ ] Stop backend server
  - [ ] Try to use app
  - [ ] Verify error handling
  - [ ] Verify graceful degradation
  - [ ] Restart backend and verify recovery

- [ ] **Backend Errors**
  - [ ] Trigger backend errors (if possible)
  - [ ] Verify error messages displayed
  - [ ] Verify app doesn't crash
  - [ ] Verify retry mechanisms work

## 📊 **Test Results**

### **Test Summary**
- [ ] **Total Tests**: _____
- [ ] **Passed**: _____ ✅
- [ ] **Failed**: _____ ❌
- [ ] **Skipped**: _____ ⏭️

### **Critical Issues Found**
- [ ] [Issue description]
- [ ] [Issue description]
- [ ] [Issue description]

### **Minor Issues Found**
- [ ] [Issue description]
- [ ] [Issue description]
- [ ] [Issue description]

### **Recommendations**
- [ ] [Action item]
- [ ] [Action item]
- [ ] [Action item]

## 🎯 **Success Criteria**

### **Must Pass (Blocking Issues)**
- [ ] User can login and logout
- [ ] User can create and manage sessions
- [ ] User can send and receive messages
- [ ] App doesn't crash during normal use
- [ ] All pages load without errors

### **Should Pass (Important Issues)**
- [ ] App responds within 2 seconds
- [ ] All features work as expected
- [ ] Error messages are user-friendly
- [ ] Navigation is intuitive
- [ ] Data persists correctly

### **Nice to Have (Enhancement Issues)**
- [ ] Smooth animations and transitions
- [ ] Excellent user experience
- [ ] Advanced features work correctly
- [ ] Performance is optimal
- [ ] Accessibility features work

## 📝 **Notes**

### **Test Environment**
- **Device**: ________________
- **OS Version**: ________________
- **App Version**: ________________
- **Backend Version**: ________________
- **Network**: ________________

### **Test Date**
- **Start Time**: ________________
- **End Time**: ________________
- **Duration**: ________________

### **Tester**
- **Name**: ________________
- **Role**: ________________
- **Contact**: ________________

---

## 🎉 **Test Completion**

When all critical tests pass, the app is ready for production use! 🚀

**Remember**: This checklist should be run after any backend changes to ensure the frontend continues to work correctly.
