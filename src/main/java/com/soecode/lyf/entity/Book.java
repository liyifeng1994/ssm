package com.soecode.lyf.entity;

/**
 * 图书实体
 */
public class Book {

	private long bookId;// 图书ID

	private String name;// 图书名称

	private int number;// 馆藏数量
	
	private String description;// 图书简介
	
	private String press;// 出版社
	
	

	/**  
     * @return the description  
     */
    
    public String getDescription() {
        return description;
    }

    /**  
     * @param description the description to set  
     */
    public void setDescription(String description) {
        this.description = description;
    }

    /**  
     * @return the press  
     */
    
    public String getPress() {
        return press;
    }

    /**  
     * @param press the press to set  
     */
    public void setPress(String press) {
        this.press = press;
    }

    public Book() {
	}

	public Book(long bookId, String name, int number) {
		this.bookId = bookId;
		this.name = name;
		this.number = number;
	}

	public long getBookId() {
		return bookId;
	}

	public void setBookId(long bookId) {
		this.bookId = bookId;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public int getNumber() {
		return number;
	}

	public void setNumber(int number) {
		this.number = number;
	}

	@Override
	public String toString() {
		return "Book [bookId=" + bookId + ", name=" + name + ", number=" + number + "]";
	}


}
