from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.chrome.options import Options
import time
import re
import shutil
import tempfile
import os

class Quillbot:
    def __init__(self, headless=True, user_data_dir=None, profile_directory="Default", copy_profile=False):
        self.headless = headless
        self.temp_dir = None
        
        # Setup Chrome options
        chrome_options = Options()
        if headless:
            chrome_options.add_argument("--headless=new")
        
        if user_data_dir:
            final_user_data_dir = user_data_dir
            
            if copy_profile:
                print(f"Copying profile from {user_data_dir} to temp directory...")
                self.temp_dir = tempfile.mkdtemp()
                final_user_data_dir = self.temp_dir
                
                # Copy only essential files to speed up
                # We need to copy the whole directory but exclude caches and lock files
                try:
                    def ignore_patterns(path, names):
                        # Ignore caches and lock files
                        ignored = ['Cache', 'Code Cache', 'GPUCache', 'ShaderCache', 'Service Worker', 'CacheStorage']
                        ignored += ['SingletonLock', 'SingletonSocket', 'SingletonCookie', 'RunningChromeVersion', 'lockfile']
                        return [n for n in names if n in ignored]

                    shutil.copytree(user_data_dir, os.path.join(self.temp_dir, "User Data"), ignore=ignore_patterns, dirs_exist_ok=True)
                    final_user_data_dir = os.path.join(self.temp_dir, "User Data")
                    print(f"Profile copied to {final_user_data_dir}")
                except Exception as e:
                    print(f"Error copying profile: {e}")
                    # Fallback to original if copy fails
                    final_user_data_dir = user_data_dir

            chrome_options.add_argument(f"--user-data-dir={final_user_data_dir}")
            chrome_options.add_argument(f"--profile-directory={profile_directory}")
            
        chrome_options.add_argument("--window-size=1920,1080")
        chrome_options.add_argument("--disable-blink-features=AutomationControlled")
        chrome_options.add_experimental_option("excludeSwitches", ["enable-automation"])
        chrome_options.add_experimental_option('useAutomationExtension', False)
        chrome_options.add_argument("user-agent=Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36")
        # Add some arguments to avoid detection/issues
        chrome_options.add_argument("--no-sandbox")
        chrome_options.add_argument("--disable-dev-shm-usage")
        
        self.driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=chrome_options)
        self.wait = WebDriverWait(self.driver, 20)

    def close(self):
        if self.driver:
            self.driver.quit()
        if self.temp_dir:
            try:
                print(f"Cleaning up temp profile at {self.temp_dir}...")
                shutil.rmtree(self.temp_dir)
            except Exception as e:
                print(f"Error cleaning up temp profile: {e}")

    def _split_text(self, text, limit=125):
        """Splits text into chunks of at most `limit` words."""
        words = re.findall(r'\b[\w\']+\b', text)
        if len(words) <= limit:
            return [text]
        
        chunks = []
        current_chunk = []
        current_word_count = 0
        
        # This is a simple split. A more robust one would respect sentences.
        # Let's try to respect sentences if possible, but fallback to word count.
        sentences = re.split(r'(?<=[.!?])\s+', text)
        
        current_chunk_str = ""
        
        for sentence in sentences:
            sentence_word_count = len(re.findall(r'\b[\w\']+\b', sentence))
            
            if current_word_count + sentence_word_count <= limit:
                current_chunk_str += sentence + " "
                current_word_count += sentence_word_count
            else:
                # If a single sentence is too long, we might need to split it (rare but possible)
                if sentence_word_count > limit:
                     # For now, just append what we have and start a new chunk with the long sentence
                     # Ideally we should split the long sentence too, but let's keep it simple for now
                     if current_chunk_str:
                         chunks.append(current_chunk_str.strip())
                     chunks.append(sentence.strip()) # This might exceed limit, but better than breaking logic
                     current_chunk_str = ""
                     current_word_count = 0
                else:
                    chunks.append(current_chunk_str.strip())
                    current_chunk_str = sentence + " "
                    current_word_count = sentence_word_count
        
        if current_chunk_str:
            chunks.append(current_chunk_str.strip())
            
        return chunks

    def _clear_input(self, input_element):
        try:
            self.driver.execute_script("arguments[0].scrollIntoView({block: 'center'});", input_element)
            time.sleep(0.5)
            
            # Clear using JS
            self.driver.execute_script("""
                arguments[0].textContent = '';
                arguments[0].innerHTML = '';
                arguments[0].dispatchEvent(new Event('input', { bubbles: true }));
                arguments[0].dispatchEvent(new Event('change', { bubbles: true }));
            """, input_element)
            time.sleep(0.5)
        except Exception as e:
            print(f"Error clearing input: {e}")

    def _input_text(self, input_element, text):
        try:
            self.driver.execute_script("arguments[0].scrollIntoView({block: 'center'});", input_element)
            # Click to focus
            from selenium.webdriver.common.action_chains import ActionChains
            actions = ActionChains(self.driver)
            actions.move_to_element(input_element).click().perform()
            time.sleep(0.5)
            
            actions.send_keys(text).perform()
            time.sleep(0.5)
            
            # Trigger input event just in case
            self.driver.execute_script("arguments[0].dispatchEvent(new Event('input', { bubbles: true }));", input_element)
            
        except Exception as e:
            print(f"Error inputting text: {e}")

    def _get_output(self):
        try:
            # Wait for output box
            output_element = self.wait.until(EC.presence_of_element_located((By.ID, "paraphraser-output-box")))
            
            # Wait until it has some text that is not the placeholder (if any)
            # But the output box might be empty initially.
            # We should wait for the "Paraphrase" button to stop spinning or something.
            # For now, just wait a bit more.
            time.sleep(5)
            
            text = output_element.text
            if not text:
                # Try getting text from child div if exists
                try:
                    child = output_element.find_element(By.CSS_SELECTOR, "div[contenteditable='true']")
                    text = child.text
                except:
                    pass
            
            return text
        except Exception as e:
            print(f"Error getting output: {e}")
            return None

    def paraphrase(self, text):
        chunks = self._split_text(text)
        full_output = ""
        
        self.driver.get("https://quillbot.com/paraphrasing-tool")
        time.sleep(2) # Wait for load
        
        for i, chunk in enumerate(chunks):
            try:
                # Find input
                input_box = self.wait.until(EC.presence_of_element_located((By.ID, "paraphraser-input-box")))
                self._clear_input(input_box)
                self._input_text(input_box, chunk)
                
                # Find and click Paraphrase button
                button = None
                
                # Try XPath first
                candidates = self.driver.find_elements(By.XPATH, "//button[contains(., 'Paraphrase')]")
                for btn in candidates:
                    if btn.is_displayed():
                        button = btn
                        break
                
                if not button:
                    # Try class based
                    candidates = self.driver.find_elements(By.CSS_SELECTOR, "button.MuiButton-containedPrimary")
                    for btn in candidates:
                        if "Paraphrase" in btn.text and btn.is_displayed():
                            button = btn
                            break
                
                if button:
                    # Check if disabled
                    if not button.is_enabled():
                         pass # Removed debug print
                    
                    # Scroll to view
                    self.driver.execute_script("arguments[0].scrollIntoView({block: 'center'});", button)
                    
                    from selenium.webdriver.common.action_chains import ActionChains
                    actions = ActionChains(self.driver)
                    actions.move_to_element(button).click().perform()
                    
                    # Wait for processing
                    time.sleep(15) # Wait longer for processing
                    
                    output = self._get_output()
                    if output:
                        full_output += output + " "
                    else:
                        print("Output empty. Dumping browser logs:")
                        for entry in self.driver.get_log('browser'):
                            print(entry)
                        
                        # Dump page source to file
                        with open("page_dump.html", "w") as f:
                            f.write(self.driver.page_source)
                        print("Dumped page source to page_dump.html")
                else:
                    print("Paraphrase button not found")
                    
            except Exception as e:
                print(f"Error processing chunk {i+1}: {e}")
                import traceback
                traceback.print_exc()
                
        return full_output.strip()

    def humanize(self, text, mode="Basic"):
        # Split by paragraphs to preserve structure
        paragraphs = text.split('\n\n')
        humanized_paragraphs = []
        
        self.driver.get("https://quillbot.com/ai-humanizer")
        time.sleep(2)
        
        # Select mode
        try:
            mode_selector = None
            if mode == "Basic":
                mode_selector = "#Paraphraser-mode-tab-0"
            elif mode == "Advanced":
                mode_selector = "#Paraphraser-mode-tab-1"
            
            if mode_selector:
                print(f"Switching to {mode} mode...")
                tab = self.wait.until(EC.presence_of_element_located((By.CSS_SELECTOR, mode_selector)))
                self.driver.execute_script("arguments[0].scrollIntoView({block: 'center'});", tab)
                from selenium.webdriver.common.action_chains import ActionChains
                actions = ActionChains(self.driver)
                actions.move_to_element(tab).click().perform()
                time.sleep(1)
                
                # Check for "Sign up" popup
                try:
                    popup = self.driver.find_elements(By.XPATH, "//*[contains(text(), 'Sign up to use Advanced Humanize')]")
                    if popup and any(p.is_displayed() for p in popup):
                        print("WARNING: Advanced mode requires sign-up. The automation may fail or require manual intervention.")
                except:
                    pass
            else:
                print(f"Unknown mode: {mode}. Using default.")
        except Exception as e:
            print(f"Error selecting mode: {e}")
        
        total_paragraphs = len(paragraphs)
        
        for p_idx, paragraph in enumerate(paragraphs):
            paragraph = paragraph.strip()
            if not paragraph:
                continue
                
            print(f"Processing paragraph {p_idx+1}/{total_paragraphs}...")
            
            # If paragraph is too long, split it into chunks
            chunks = self._split_text(paragraph)
            paragraph_output = ""
            
            for i, chunk in enumerate(chunks):
                try:
                    input_box = self.wait.until(EC.presence_of_element_located((By.ID, "paraphraser-input-box")))
                    self._clear_input(input_box)
                    self._input_text(input_box, chunk)
                    
                    # Find and click Humanize button
                    button = None
                    candidates = self.driver.find_elements(By.XPATH, "//button[contains(., 'Humanize')]")
                    for btn in candidates:
                        if btn.is_displayed():
                            button = btn
                            break
                    
                    if button:
                        self.driver.execute_script("arguments[0].scrollIntoView({block: 'center'});", button)
                        
                        from selenium.webdriver.common.action_chains import ActionChains
                        actions = ActionChains(self.driver)
                        actions.move_to_element(button).click().perform()
                        
                        time.sleep(15)
                        
                        output = self._get_output()
                        if output:
                            paragraph_output += output + " "
                    else:
                        print("Humanize button not found")
                        # Fallback to original chunk if failed
                        paragraph_output += chunk + " "
                        
                except Exception as e:
                    print(f"Error processing chunk {i+1} of paragraph {p_idx+1}: {e}")
                    paragraph_output += chunk + " "
            
            humanized_paragraphs.append(paragraph_output.strip())
            
        return "\n\n".join(humanized_paragraphs)
