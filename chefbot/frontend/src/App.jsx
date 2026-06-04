import { useState, useRef, useEffect } from 'react'
import { MdRestartAlt, MdArrowForward } from 'react-icons/md'
import { FaUser, FaUtensils } from 'react-icons/fa'
import './App.css'

const LANGUAGES = {
  en: 'English',
  hi: 'Hindi',
  mr: 'Marathi',
  ta: 'Tamil',
  te: 'Telugu',
  kn: 'Kannada',
  ml: 'Malayalam',
  gu: 'Gujarati',
  bn: 'Bengali',
  pa: 'Punjabi',
  es: 'Spanish',
  fr: 'French',
  de: 'German',
}

// Backend API URL - use environment variable or default
const API_BASE_URL = import.meta.env.VITE_BACKEND_URL || 'https://chefbot-production-8ebc.up.railway.app'

const SUGGESTIONS = [
  "How do I make butter chicken?",
  "Quick 15-minute recipes",
  "Vegetarian dinner ideas",
  "How to make samosas?",
]

function App() {
  const [messages, setMessages] = useState([])
  const [inputText, setInputText] = useState('')
  const [isLoading, setIsLoading] = useState(false)
  const [sessionId, setSessionId] = useState(() => crypto.randomUUID())
  const [selectedLanguage, setSelectedLanguage] = useState('en')
  const messagesEndRef = useRef(null)
  const textareaRef = useRef(null)

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' })
  }, [messages, isLoading])

  useEffect(() => {
    const ta = textareaRef.current
    if (!ta) return
    ta.style.height = 'auto'
    ta.style.height = Math.min(ta.scrollHeight, 140) + 'px'
  }, [inputText])

  const handleSend = async () => {
    if (!inputText.trim() || isLoading) return

    const userMessage = inputText.trim()
    setInputText('')

    setMessages(prev => [...prev, {
      text: userMessage,
      sender: 'user',
      timestamp: new Date(),
      language: selectedLanguage,
    }])
    setIsLoading(true)

    try {
      const res = await fetch(`${API_BASE_URL}/chat`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ 
          message: userMessage, 
          session_id: sessionId,
          language: selectedLanguage,
        }),
      })

      if (!res.ok) throw new Error(`Server error: ${res.status}`)

      const data = await res.json()

      setMessages(prev => [...prev, {
        text: data.response,
        sender: 'bot',
        timestamp: new Date(),
        language: selectedLanguage,
      }])

      if (data.session_id !== sessionId) setSessionId(data.session_id)

    } catch (err) {
      console.error(err)
      setMessages(prev => [...prev, {
        text: `⚠️ Unable to connect to backend. Make sure ${API_BASE_URL} is running.`,
        sender: 'bot',
        timestamp: new Date(),
        isError: true,
      }])
    } finally {
      setIsLoading(false)
    }
  }

  const handleReset = async () => {
    try {
      await fetch(`${API_BASE_URL}/reset`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ session_id: sessionId }),
      })
    } catch (_) { /* ignore */ }
    setMessages([])
    setSessionId(crypto.randomUUID())
  }

  const handleKeyDown = (e) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault()
      handleSend()
    }
  }

  const formatTime = (date) =>
    date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })

  return (
    <div className="app">

      {/* ── Header ── */}
      <header className="header">
        <div className="header-inner">
          <div className="header-brand">
            <div className="brand-logo">
              <FaUtensils size={32} />
            </div>
            <div className="brand-text">
              <h1 className="brand-name">ChefBot</h1>
              <p className="brand-subtitle">Culinary Assistant</p>
            </div>
          </div>
          
          <div className="header-controls">
            <div className="language-selector-wrapper">
              <label htmlFor="language-select" className="language-label">Language:</label>
              <select
                id="language-select"
                className="language-select"
                value={selectedLanguage}
                onChange={(e) => setSelectedLanguage(e.target.value)}
              >
                {Object.entries(LANGUAGES).map(([code, name]) => (
                  <option key={code} value={code}>{name}</option>
                ))}
              </select>
            </div>
            
            <button 
              className="btn-new-chat" 
              onClick={handleReset}
              disabled={messages.length === 0}
              title="Start a new chat"
            >
              <MdRestartAlt size={18} />
              <span>New Chat</span>
            </button>
          </div>
        </div>
      </header>

      {/* ── Main Content ── */}
      <main className="main-content">
        <div className="messages-wrapper">

          {messages.length === 0 ? (
            <div className="empty-state">
              <div className="empty-illustration">
                <FaUtensils size={80} />
              </div>
              <h2 className="empty-title">Welcome to ChefBot</h2>
              <p className="empty-subtitle">Your personal culinary guide • Speak in {LANGUAGES[selectedLanguage]}</p>
              
              <div className="suggestions-section">
                <p className="suggestions-title">Try asking:</p>
                <div className="suggestions-grid">
                  {SUGGESTIONS.map((s) => (
                    <button 
                      key={s} 
                      className="suggestion-btn" 
                      onClick={() => setInputText(s)}
                    >
                      {s}
                    </button>
                  ))}
                </div>
              </div>
            </div>
          ) : (
            <div className="messages-list">
              {messages.map((msg, i) => (
                <div key={i} className={`msg-container msg-${msg.sender}${msg.isError ? ' msg-error' : ''}`}>
                  <div className="msg-avatar">
                    {msg.sender === 'user' ? (
                      <FaUser size={18} />
                    ) : (
                      <FaUtensils size={18} />
                    )}
                  </div>
                  <div className="msg-box">
                    <div className="msg-body">
                      <p className="msg-text">{msg.text}</p>
                    </div>
                    <div className="msg-meta">
                      {msg.language && msg.sender === 'user' && (
                        <span className="msg-lang">{LANGUAGES[msg.language]}</span>
                      )}
                      <span>{formatTime(msg.timestamp)}</span>
                    </div>
                  </div>
                </div>
              ))}

              {isLoading && (
                <div className="msg-container msg-bot">
                  <div className="msg-avatar">
                    <FaUtensils size={18} />
                  </div>
                  <div className="msg-box">
                    <div className="msg-body">
                      <div className="typing-dots">
                        <span className="dot" />
                        <span className="dot" />
                        <span className="dot" />
                      </div>
                    </div>
                  </div>
                </div>
              )}

              <div ref={messagesEndRef} />
            </div>
          )}
        </div>
      </main>

      {/* ── Input Section ── */}
      <div className="input-section">
        <div className="input-inner">
          <div className="input-field-wrapper">
            <textarea
              ref={textareaRef}
              className="input-field"
              placeholder="Type your message..."
              value={inputText}
              onChange={(e) => setInputText(e.target.value)}
              onKeyDown={handleKeyDown}
              disabled={isLoading}
              rows={1}
            />
            <button
              className="btn-send"
              onClick={handleSend}
              disabled={!inputText.trim() || isLoading}
              title="Send message (Enter)"
            >
              <MdArrowForward size={20} />
            </button>
          </div>
          
          <div className="input-info">
            <span className="language-active">📢 Responding in: <strong>{LANGUAGES[selectedLanguage]}</strong></span>
            <span className="input-hint">Enter • Shift+Enter for new line</span>
          </div>
        </div>
      </div>

      {/* ── Footer ── */}
      <footer className="footer">
        <p className="footer-text">ChefBot • Your multilingual culinary companion</p>
      </footer>

    </div>
  )
}

export default App
